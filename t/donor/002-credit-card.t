use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    # Obtendo a callback url.
    rest_post "/api/donor/$donor_id/credit-card",
        name  => "get callback url",
        code  => 200,
        stash => "c1",
        [ cpf => random_cpf() ],
    ;

    my $content;
    my $callback;
    stash_test "c1" => sub {
        my $res = shift;

        like ($res->{href}, qr/callback-for-token/, "callback for token");
        is ($res->{method}, "POST", "method post");

        my $furl = Furl->new(timeout => 20);

        my $request = $furl->post(
            $res->{href},
            [ 'Content-Type' => "application/json" ],
            encode_json {
                name_on_card => "This is a fake credit card",
                csc          => "123",
                number       => "5268590528188853",
                validity     => "201801",
                brand        => "mastercard",
            },
        );

        ok ($request->is_success, "post success");
        $content  = $request->decoded_content;
        $callback = URI->new($res->{href})->query_param('callback');
    };

    # Cadastrando um plano antes de invocar o callback do httpcb para que possamos atualizar no korduv também.
    rest_put "/api/donor/$donor_id/plan",
        name   => "Plano de um doador",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    # Simulando o callback.
    rest_post [ $callback ],
        name    => 'receiving callback',
        headers => [ 'Content-Type' => "application/json" ],
        code    => 200,
        data    => $content,
    ;

    ok (my $user = $schema->resultset("Donor")->find($donor_id));

    my $content_as_json = decode_json $content;
    is_deeply(
        decode_json($user->flotum_preferred_credit_card),
        {
            map { $_ => $content_as_json->{$_} }
              qw(conjecture_brand created_at id mask validity)
        },
        "flotum preferred creditcard"
    );

    # Listagem.
    rest_get [ "/api/donor", $donor_id, "credit-card" ],
        name  => "list credit card",
        stash => "l1",
    ;

    my $credit_card_id;
    stash_test "l1" => sub {
        my $res = shift;

        is_deeply(
            $res->{credit_cards},
            [ $content_as_json ],
        );

        $credit_card_id = $res->{credit_cards}->[0]->{id};
    };

    # Deletando cartão de crédito.
    rest_delete [ "/api/donor", $donor_id, "credit-card", $credit_card_id ],
        name => "delete credit card",
        code => 204,
    ;

    is(
        $user->discard_changes->flotum_preferred_credit_card,
        undef,
        "user has no preferred credit card",
    );

    rest_get [ "/api/donor", $donor_id, "credit-card" ],
        name  => "list credit card again",
        stash => "l2",
    ;

    is_deeply(
        stash "l2",
        { credit_cards => [] },
        "empty credit card list",
    );

};

done_testing();

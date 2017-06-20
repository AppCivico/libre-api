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
    rest_post "/api/donor/$donor_id/plan",
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

    ok (my $donor = $schema->resultset("Donor")->find($donor_id));

    my $flotum_preferred_credit_card = decode_json $donor->flotum_preferred_credit_card;
    my $credit_card_id = $flotum_preferred_credit_card->{id};

    # Não devo poder deletar o cartão de crédito sem antes cancelar o plano.
    rest_delete [ "/api/donor", $donor_id, "credit-card", $credit_card_id ],
        name    => "delete credit card",
        is_fail => 1,
        code    => 400,
    ;

    # Cancelando o plano.
    my $plan_id = stash "user_plan.id";
    rest_post [ "api", "donor", $donor_id, "plan", stash "user_plan.id", "cancel" ],
        name => "cancel plan",
        code => 200
    ;

    # Deletando cartão de crédito.
    rest_delete [ "/api/donor", $donor_id, "credit-card", $credit_card_id ],
        name => "delete credit card",
        code => 204,
    ;

    is(
        $donor->discard_changes->flotum_preferred_credit_card,
        undef,
        "user has no preferred credit card",
    );

    rest_get [ "/api/donor", $donor_id, "credit-card" ],
        name  => "list credit card",
        stash => "l1",
    ;

    is_deeply(
        stash "l1",
        { credit_cards => [] },
        "empty credit card list",
    );
};

done_testing();

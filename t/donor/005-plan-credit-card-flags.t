use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    create_journalist;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";
    my $journalist_id = stash "journalist.id";

    rest_get "/api/donor/$donor_id",
        name  => "list a donor without plan",
    ;

    # Doador com plano mas sem cartão de crédito
    rest_post "/api/donor/$donor_id/plan",
        name    => "Donor plan",
        params  => {
            amount => fake_int(2001, 100000)->(),
        }
    ;

    rest_get "/api/donor/$donor_id",
        name  => "list a donor with plan without credit card",
    ;

    # Doador com cartão de crédito
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

    rest_get "/api/donor/$donor_id",
        name  => "list a donor with both plan and credit card",
    ;
};

done_testing();
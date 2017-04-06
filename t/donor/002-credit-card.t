use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

my $furl = Furl->new( timeout => 15, );

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    # Obtendo a callback url.
    rest_post "/v1/user/$donor_id/credit-card",
        name  => "get callback url",
        code  => 200,
        stash => "c1",
        [ cpf => random_cpf() ],
    ;

    my $content;
    my $callback;
    stash_test "c1" => sub {
        my $res = shift;

        like($res->{href}, qr/callback-for-token/, "callback for token");
        is($res->{method}, "POST", "method post");

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
        $callback = URI->new($res->{href})->query_param('callback') 
    };

    # Simulando o callback.
    rest_post [ $callback ],
        name    => 'receiving callback',
        headers => [ 'Content-Type' => "application/json" ],
        code    => 200,
        data    => $content,
    ;

    # Neste ponto o cartão de crédito já deve ter sido cadastrado.
    # Listando.
    rest_get [ "/v1/user", $donor_id, "credit-card" ],
        name  => "list credit card",
        stash => "l1",
    ;

    p [ stash 'l1'];
};

done_testing();

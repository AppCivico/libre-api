use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {

    my $email = fake_email()->();
    my $password = "foobarquux1";

    create_donor(
        email    => $email,
        password => $password,
    );

    rest_post "/v1/user/plan/",
        name    => "Plano de um doador",
        code    => 200,
        params  => {
            amount => fake_int(30, 100)->(),
        }
    ;

};

done_testing();
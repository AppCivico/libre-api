use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {

    create_donor;
    api_auth_as user_id => stash "donor.id";
    
    my $donor_id = stash "donor.id";

    rest_get "v1/user/$donor_id/plan",
        name  => "list without plan",
        stash => "l1",
    ;

    stash_test "l1" => sub {
        my $res = shift;

        is_deeply ($res->{user_plan}, [], "donor has no plan yet");
    };

    rest_post "/v1/user/$donor_id/plan",
        name    => "Plano de um doador",
        code    => 200,
        params  => {
            amount => fake_int(30, 100)->(),
        }
    ;

    # O doador não pode escolher um valor de plano menor que 20
    rest_post "/v1/user/$donor_id/plan",
        name    => "Plano de um  doador",
        is_fail => 1,
        code    => 400,
        params  => {
            amount  => fake_int(-100, 19)->(),
            user_id => $donor_id,
        }
    ;

    rest_get "v1/user/$donor_id/plan",
        name  => "Listando plano de um doador",
        stash => "p1",
    ;

};

done_testing();

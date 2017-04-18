use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    rest_get "v1/donor/$donor_id/plan",
        name  => "list without plan",
        stash => "l1",
    ;

    stash_test "l1" => sub {
        my $res = shift;

        is_deeply ($res->{user_plan}, [], "donor has no plan yet");
    };

    rest_post "/v1/donor/$donor_id/plan",
        name    => "Plano de um doador",
        code    => 200,
        params  => {
            amount => fake_int(30, 100)->(),
        }
    ;

    # O doador não pode escolher um valor de plano menor que 20
    rest_post "/v1/donor/$donor_id/plan",
        name    => "Plano de um  doador",
        is_fail => 1,
        params  => {
            amount  => fake_int(-100, 9)->(),
        }
    ;

    rest_get "v1/donor/$donor_id/plan",
        name  => "Listando plano de um doador",
        stash => "l2",
    ;

    stash_test "l2" => sub {
        my $res = shift;

        is ($res->{user_plan}->[0]->{valid_until}, undef, "no valid until");
        is ($res->{user_plan}->[0]->{user_id}, $donor_id, "user id is donor id");
    };

};

done_testing();

use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    rest_get "/api/donor/$donor_id/plan",
        name  => "list without plan",
        stash => "l1",
    ;

    is_deeply (
        (stash "l1")->{user_plan},
        [],
        "donor has no plan yet",
    );

    rest_put "/api/donor/$donor_id/plan",
        name   => "Plano de um doador",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    # O doador não pode escolher um valor de plano menor que 20
    rest_put "/api/donor/$donor_id/plan",
        name    => "Plano de um  doador",
        is_fail => 1,
        [
            amount => fake_int(-100, 1900)->()
        ],
    ;

    rest_get "/api/donor/$donor_id/plan",
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

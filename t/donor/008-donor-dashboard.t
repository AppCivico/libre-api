use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use DateTime;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";
    my $amount        = fake_int(2001, 100000)->();

    rest_post "/api/donor/$donor_id/plan",
        name   => "create first donor plan",
        stash  => "donor_plan",
        params => {
            amount => $amount,
        },
    ;

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
    ;

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
    ;

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
    ;

    my $plan_id  = (stash("donor_plan")->{id});

    rest_get "/api/donor/$donor_id/dashboard",
        name  => "donor dashboard",
        stash => "donor_dashboard"
    ;

    is_deeply(
        (stash "donor_dashboard"),
        {
            libres_donated   => 3,
            user_plan_amount => $amount,
        },
        'Donor dashboard'
    );
};

done_testing();
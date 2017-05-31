use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
	create_journalist;
	create_donor;
	api_auth_as user_id => stash "donor.id";

	my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";

    rest_put "/api/donor/$donor_id/plan",
        name   => "create donor plan",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
    	},
    ;

    my $plan_id = (stash("user_plan")->{id});

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s1",
    ;

    rest_get "/api/donor/$donor_id/plan/$plan_id",
    	name  => "counting once",
    	stash => "c1",
    ;

    is((stash("c1")->{total_supports}), 1, 'One libre, as expected');

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s2",
    ;

    rest_get "/api/donor/$donor_id/plan/$plan_id",
    	name  => "counting once again",
    	stash => "c2"
    ;

    is((stash("c2")->{total_supports}), 2, 'two libres, as expected');
};

done_testing();
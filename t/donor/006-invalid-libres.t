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

    rest_post "/api/journalist/$journalist_id/support",
            name  => "donate to a journalist",
            stash => "s1",
    ;

    # Simulando invalidação do plano
    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id})->update(
    	{ invalided_at => \"NOW()" },
    );
    my $libre = $schema->resultset("Libre")->find((stash("s1"))->{id})->update(
    	{ user_plan_id => undef },
    );

    # Invalidando libres
    my $invalided_libre = $schema->resultset("Libre")->invalid_libres();
    
    my $invalid_bool = 1;
    is($invalided_libre->invalid, $invalid_bool, 'Libre invalid, as expected');
};

done_testing();
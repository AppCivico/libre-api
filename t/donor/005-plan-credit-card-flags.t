use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
	create_donor;
	api_auth_as user_id => stash "donor.id";

	my $donor_id = stash "donor.id";

	rest_get "/api/donor/$donor_id",
        name  => "list without plan",
        stash => "l1",
    ;

};

done_testing();
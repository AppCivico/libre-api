use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use HTTP::Request::Common qw(GET);

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    rest_put "/api/donor/$donor_id/plan",
        name   => "creating donor plan",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    # Simulando o callback do korduv.
    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id});
    ok (my $callback_id = $user_plan->callback_id, "get callback_id");

    my $req = request GET "korduv/success-renewal/$callback_id";
    is ($req->status_line, "200 OK", "callback success");

};

done_testing();

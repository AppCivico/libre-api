use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use HTTP::Request::Common qw(GET);
use DateTime;
use DDP;

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

    rest_get "api/donor/$donor_id/plan",
        name  => "List a valid user plan",
        stash => "l1",
    ;

    stash_test "l1" => sub {
        my $res = shift;

        my $invalided_at          = $res->{user_plan}->[0]->{invalided_at};
        my $expected_invalided_at = undef;

        is($invalided_at , $expected_invalided_at, 'Valid user plan');
    };

    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id});
    ok (my $callback_id = $user_plan->callback_id, "get callback_id");

    my $req = request GET "korduv/fail-forever/$callback_id";
    is ($req->status_line, "200 OK", "callback success");

    rest_get "api/donor/$donor_id/plan",
        name  => "List a user plan",
        stash => "l2",
    ;

    stash_test "l2" => sub {
        my $res = shift;

        my $invalided_at = $res->{user_plan}->[0]->{invalided_at};

        ok(defined($invalided_at), "User plan is invalid");
    };
};

done_testing();
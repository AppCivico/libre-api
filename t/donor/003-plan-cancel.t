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

    # Mockando cartão de crédito para fazer a subscription no korduv.
    ok (
        $schema->resultset("Donor")->find($donor_id)->update({
            flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
            flotum_preferred_credit_card =>
'"{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"3acd6d0c-58c0-40b9-9144-84a8b5f14806","mask":"5268*********853"}',
        }),
        'mock credit card'
    );

    rest_post "/api/donor/$donor_id/plan",
        name   => "create donor plan",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    my $plan_id = stash "user_plan.id";
    ok (my $user_plan = $schema->resultset("UserPlan")->find($plan_id), "get user plan");
    ok ($user_plan->discard_changes(), 'discard changes');
    is ($user_plan->canceled, 0, "not canceled yet");
    is ($user_plan->canceled_at, undef, "canceled_at=undef");

    # Cancelando o plano.
    rest_post "/api/donor/$donor_id/plan/$plan_id/cancel",
        name => "cancel plan",
        code => 200,
    ;

    ok ($user_plan->discard_changes(), 'discard changes');
    ok ($user_plan->canceled, "plan canceled");
    ok (defined($user_plan->canceled_at), "canceled_at filled");
    is ($user_plan->cancel_on_korduv, 0, "cancel_on_korduv=false");
};

done_testing();

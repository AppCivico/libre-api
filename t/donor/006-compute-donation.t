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
            amount => 2000,
        },
    ;

    my $user_plan_id = (stash("user_plan")->{id});
    my $user_plan = $schema->resultset("UserPlan")->find($user_plan_id);
    my $httpcb_rs = $schema->resultset("HttpCallbackToken");

    # Mockando um pagamento para simular o callback de compute donation.
    ok (
        my $payment = $schema->resultset("Payment")->create(
            {
                donor_id     => $donor_id,
                user_plan_id => $user_plan_id,
                amount       => 2000,
                gateway_tax  => 10.5,
            },
        ),
        "fake payment",
    );

    ok (
        my $token = $httpcb_rs->create_for_action(
        "payment-success-renewal",
            {
                user_id      => $donor_id,
                user_plan_id => $user_plan_id,
                payment_id   => $payment->id,
            }
        ),
        "fake http callback of fake payment",
    );
};

done_testing();

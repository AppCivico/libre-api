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
        name   => "creating donor plan",
        stash  => "user_plan",
        params => {
            amount => 2000,
        },
    ;

    # Simulando o callback do korduv.
    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id});
    ok (my $callback_id = $user_plan->callback_id, "get callback_id");

    my $now = $schema->resultset("UserPlan")->search(
        {},
        {
            select => [ \"NOW()" ],
            as     => [ "now" ],
        }
    )->next();

    my $last_payment_received_at = $now->get_column("now");
    my $last_charge_created_at   = $now->get_column("now");

    rest_post $Libre::Test::Further::korduv->{on_charge_renewed},
        name    => "callback do korduv",
        code    => 200,
        headers => [ 'content-type' => "application/json" ],
        data    => encode_json {
            status => {
                cancel_reason            => "foobar",
                cancelled_at             => undef,
                last_payment_received_at => $last_payment_received_at,
                last_charge_created_at   => $last_charge_created_at,
                status                   => "active",
                next_billing_at          => "2017-01-01 12:00:00",
                paid_until               => "2017-01-01 12:00:00",
            },
            last_subscription_charge => {
                charge_amount     => 2000,
                charge_created_at => "2017-06-01 01:00:00",
            },
        },
    ;

    my $httpcb_rs = $schema->resultset("HttpCallbackToken");
    is ($httpcb_rs->count(), "1", "just one http callback token");
    ok (
        my $httpcb = $httpcb_rs->search( { action => "payment-success-renewal" } )->next,
        "callback action",
    );

    ok (
        my $payment = $schema->resultset("Payment")->search(
            {
                donor_id     => $donor_id,
                user_plan_id => $user_plan->id,
            },
        )->next(),
        "master payment created",
    );

    is_deeply (
        decode_json($httpcb->extra_args),
        {
            user_id      => $donor_id,
            user_plan_id => $user_plan->id,
            payment_id   => $payment->id,
        },
        "http callback has extra args",
    );

    rest_post [ "callback-for-token", $httpcb->token ],
        name => "http callback triggered",
        code => 200,
    ;

    is($schema->resultset("EmailQueue")->count, 1, 'email queued');
};

done_testing();

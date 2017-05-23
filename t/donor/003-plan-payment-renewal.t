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
                last_charge_created_at   =>  $last_charge_created_at,
                status                   => "active",
                next_billing_at          => "2017-01-01 12:00:00",
                paid_until               => "2017-01-01 12:00:00",
            },
        },
    ;

    my $httpcb_rs = $schema->resultset("HttpCallbackToken");
    is ($httpcb_rs->count(), "1", "just one http callback token");
    ok (
        my $httpcb = $httpcb_rs->search( { action => "payment-success-renewal" } )->next,
        "callback action",
    );

    is_deeply (
        decode_json($httpcb->extra_args),
        {
            user_id      => $donor_id,
            user_plan_id => $user_plan->id,
        },
        "http callback has extra args",
    );

    rest_post [ "callback-for-token", $httpcb->token ],
        name => "http callback triggered",
        code => 200,
    ;

    # TODO Testar a distribuição de libres.
};

done_testing();

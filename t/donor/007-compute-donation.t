use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use HTTP::Request::Common qw(GET);

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id    = stash "donor.id";
    my $plan_amount = 2500;

    rest_put "/api/donor/$donor_id/plan",
        name   => "creating donor plan",
        stash  => "user_plan",
        params => {
            amount => $plan_amount,
        },
    ;

    # Criando dois jornalistas que receberão doações.
    my @journalist_ids = ();
    for ( 1 .. 2 ) {
        create_journalist;
        push @journalist_ids, (stash "journalist.id");
    }

    # Fazendo três doações para o jornalista 1, e duas doações para o jornalista 2.
    rest_post "/api/journalist/$journalist_ids[0]/support", name => "support journalist 1" for 1 .. 3;
    rest_post "/api/journalist/$journalist_ids[1]/support", name => "support journalist 2" for 1 .. 2;

    my $user_plan_id = (stash("user_plan")->{id});
    my $user_plan = $schema->resultset("UserPlan")->find($user_plan_id);
    my $httpcb_rs = $schema->resultset("HttpCallbackToken");

    # Mockando um pagamento para simular o callback de compute donation.
    ok (
        my $payment = $schema->resultset("Payment")->create(
            {
                donor_id     => $donor_id,
                user_plan_id => $user_plan_id,
                amount       => $plan_amount,
                gateway_tax  => 11.5,
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

    rest_post [ "callback-for-token", $token ],
        name => "http callback triggered",
        code => 200,
    ;

    # TODO Testar os dados dentro da tabela money_transfer.
};

done_testing();

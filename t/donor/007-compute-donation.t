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

    rest_post "/api/donor/$donor_id/plan",
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
    for ( 1 .. 3 ) {
        rest_post "/api/journalist/$journalist_ids[0]/support",
            name => "support journalist 1",
            [
                page_title   => fake_sentences(1)->(),
                page_referer => fake_referer->(),
            ],
        ;
    }

    for ( 1 .. 2 ) {
        rest_post "/api/journalist/$journalist_ids[1]/support",
            name => "support journalist 2",
            [
                page_title   => fake_sentences(1)->(),
                page_referer => fake_referer->(),
            ],
        ;
    }

    my $user_plan_id = (stash("user_plan")->{id});
    my $user_plan = $schema->resultset("UserPlan")->find($user_plan_id);
    my $httpcb_rs = $schema->resultset("HttpCallbackToken");

    # Mockando um pagamento para simular o callback de compute donation.
    ok(
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

    ok(
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

    ok( $user_plan->discard_changes, 'user_plan discard changes' );
    ok( defined($user_plan->last_close_at), 'user_plan.last_close_at is defined' );

    # O jornalista 1 deve receber R$ 13,26.
    is(
        $schema->resultset("MoneyTransfer")->search(
            {
                journalist_id => $journalist_ids[0],
                amount        => 1326,
                transferred   => "false",
            },
        )->count,
        "1",
        'journalist 1 will receive R$ 13,26',
    );

    # E o jornalista 2 deve receber R$ 8,84.
    is(
        $schema->resultset("MoneyTransfer")->search(
            {
                journalist_id => $journalist_ids[1],
                amount        => 884,
                transferred   => "false",
            },
        )->count,
        "1",
        'journalist 2 will receive R$ 8,84',
    );

    # Se houver um novo callback do compute_donations, não deve criar mais nenhuma transferência pois nenhum libre
    # será doado.
    use_ok 'Libre::Worker::BankTeller';
    my $worker = new_ok( 'Libre::Worker::BankTeller', [ schema => $schema, log => Libre->log ] );

    is(
        $schema->resultset("MoneyTransfer")->search( { 'me.transferred' => "false" } )->count,
        2,
        "money_transfer count=2",
    );

    ok( $worker->run_once(), 'run once' );
    ok( $worker->run_once(), 'run once' );

    is(
        $schema->resultset("MoneyTransfer")->search( { 'me.transferred' => "false" } )->count,
        0,
        "money_transfer count=0",
    );

    undef $token;
    ok(
        $token = $httpcb_rs->create_for_action(
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
        name => "http callback triggered again",
        code => 200,
    ;

    is(
        $schema->resultset("MoneyTransfer")->search( { 'me.transferred' => "false" } )->count,
        0,
        "money_transfer count=0",
    );
};

done_testing();

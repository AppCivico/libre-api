use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use Libre::Utils;

my $schema = Libre->model("DB");

db_transaction {
    use_ok 'Libre::Worker::BankTeller';
    use_ok 'Libre::Mailer::Template';

    my $worker = new_ok('Libre::Worker::BankTeller', [ schema => $schema, log => Libre->log ]);

    ok( $worker->does('Libre::Worker'), 'Libre::Worker::BankTeller does Libre::Worker' );

    # Criando alguns jornalistas para fakear pagamentos.
    my @journalist_ids = ();
    for ( 1 .. 3 ) {
        create_journalist;
        api_auth_as user_id => stash "journalist.id";

        my $journalist_id = stash "journalist.id";
        push @journalist_ids, $journalist_id;

        # Assumindo que eles se autenticaram via authlink.
        rest_get [ "api", "journalist", $journalist_id, "authlink" ], name  => "get authlink";
    }

    # Criando um doador.
    create_donor;
    my $donor_id = stash "donor.id";

    # Criando um plano para o doador.
    api_auth_as user_id => $donor_id;
    rest_post "/api/donor/$donor_id/plan",
        name   => "creating donor plan",
        stash  => "user_plan",
        params => { amount => 2000 },
    ;

    # Fake payment.
    my $user_plan_id = (stash("user_plan")->{id});
    ok(
        my $payment = $schema->resultset("Payment")->create(
            {
                donor_id     => $donor_id,
                user_plan_id => $user_plan_id,
                amount       => 2000,
                gateway_tax  => 11.5,
            },
        ),
        "fake payment",
    );

    my $money_transfer_rs = $schema->resultset("MoneyTransfer");
    ok(
        $money_transfer_rs->create(
            {
                journalist_id => $journalist_ids[0],
                amount        => 100,
                created_at    => \"(NOW() - '30 days'::interval)",
                from_donor_id            => $donor_id,
                from_payment_id          => $payment->id,
                supports_received        => fake_int(1, 10)->(),
                donor_plan_last_close_at => fake_past_datetime()->(),
            },
        ),
        "transfer to the first journalist",
    );

    ok(
        $money_transfer_rs->create(
            {
                journalist_id => $journalist_ids[1],
                amount        => 100,
                created_at    => \"(NOW() - '20 days'::interval)",
                from_donor_id            => $donor_id,
                from_payment_id          => $payment->id,
                supports_received        => fake_int(1, 10)->(),
                donor_plan_last_close_at => fake_past_datetime()->(),
            },
        ),
        "transfer to the second journalist",
    );

    ok(
        $money_transfer_rs->create(
            {
                journalist_id => $journalist_ids[2],
                amount        => 100,
                created_at    => \"(NOW() - '15 days'::interval)",
                from_donor_id            => $donor_id,
                from_payment_id          => $payment->id,
                supports_received        => fake_int(1, 10)->(),
                donor_plan_last_close_at => fake_past_datetime()->(),
            },
        ),
        "transfer to the first journalist",
    );

    ok( $worker->run_once(), 'run once' );

    # A doação mais antiga (do primeiro jornalista) deve estar com paid=true.
    is(
        $money_transfer_rs->search(
            {
                journalist_id => $journalist_ids[0],
                transferred   => "true",
            },
        )
        ->count,
        "1",
        'transferred the oldest order',
    );

    is ($money_transfer_rs->search( { transferred => "false" } )->count, "2", "two pending transfers");
};

done_testing();


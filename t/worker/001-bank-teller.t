use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use Libre::Utils;

my $schema = Libre->model("DB");

db_transaction {
    use_ok 'Libre::Worker::BankTeller';
    use_ok 'Libre::Mailer::Template';

    my $worker = new_ok('Libre::Worker::BankTeller', [ schema => $schema ]);

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

    my $money_transfer_rs = $schema->resultset("MoneyTransfer");
    ok(
        $money_transfer_rs->create(
            {
                journalist_id => $journalist_ids[0],
                amount        => 100,
                created_at    => \"(NOW() - '30 days'::interval)",
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


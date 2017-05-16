use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id      = stash "donor.id";
    my $journalist_id = stash "journalist.id";

    rest_get "/api/donor/$donor_id/plan",
        name  => "list without plan",
        stash => "l1",
    ;

    is_deeply (
        (stash "l1")->{user_plan},
        [],
        "donor has no plan yet",
    );

    # CRUD de plano.
    db_transaction {
        diag "testando a criação do plano";
        rest_post "/api/donor/$donor_id/plan",
            name    => "Plano de um doador",
            [ amount => fake_int(2001, 100000)->() ],
        ;

        # O doador não pode escolher um valor de plano menor que 20
        rest_post "/api/donor/$donor_id/plan",
            name    => "Plano de um  doador",
            is_fail => 1,
            [ amount => fake_int(-100, 1900)->() ],
        ;

        rest_get "/api/donor/$donor_id/plan",
            name  => "Listando plano de um doador",
            stash => "l2",
        ;

        stash_test "l2" => sub {
            my $res = shift;

            is ($res->{user_plan}->[0]->{valid_until}, undef, "no valid until");
            is ($res->{user_plan}->[0]->{user_id}, $donor_id, "user id is donor id");
        };
        die "rollback";
    };

    db_transaction {
        diag("testando o fluxo dos libres orfaos");

        # Quando um novo plano é criado, os libres órfãos devem ser atrelados ao mesmo.
        rest_post "/api/journalist/$journalist_id/support",
            name  => "support a journalist",
            stash => "s1",
        ;

        # Os libres deve vir com user_plan_id null.
        ok (my $libre = $schema->resultset("Libre")->find(stash "s1.id"), "select random donation");
        is (
            $libre->user_plan_id,
            undef,
            "donation user_plan_id=null",
        );

        # Criando um plano.
        rest_post "/api/donor/$donor_id/plan",
            name    => "creating donor plan",
            stash   => "p1",
            [ amount => fake_int(2001, 100000)->() ]
        ;

        # Testando se os libres órfãos agora estão atrelados ao id do plano criado.
        is (
            $libre->discard_changes->user_plan_id,
            stash "p1.id",
            "donation user_plan_id=plan_id",
        );
        die "rollback";
    };

    db_transaction {
        diag("testando o fluxo dos libres orfaos antigos");

        # Os libres que são mais antigos que $ENV{LIBRE_ORPHAN_EXPIRATION_TIME} devem continuar com user_plan_id=null.
        rest_post "/api/journalist/$journalist_id/support",
            name  => "support a journalist",
            stash => "s2",
        ;

        ok (my $libre = $schema->resultset("Libre")->find(stash "s2.id"), "select donation");
        is (
            $libre->user_plan_id,
            undef,
            "donation user_plan_id=null",
        );

        # Atualizando o created_at da doação para 90 dias atrás.
        ok(
            $libre->update( { created_at => \"( NOW() - '90 days'::interval )" } ),
            "set libre created_at to 90 days ago",
        );

        # Ok, agora vou criar um plano. O esperado é que NÃO atrele o libre a este plano.
        rest_post "/api/donor/$donor_id/plan",
            name  => "create donor plan",
            [ amount => fake_int(2001, 100000)->() ]
        ;

        is (
            $libre->discard_changes->user_plan_id,
            undef,
            "libre user_plan_id=null",
        );
        die "rollback";
    };

    db_transaction {
        diag "testando ciclo de planos";

        # Quando um usuário já possuía um plano e adiciona um novo, o plano antigo deve ser fechado.
        rest_post "/api/donor/$donor_id/plan",
            name  => "add plan",
            stash => "p2",
            [ amount => fake_int(2001, 100000)->() ]
        ;

        my $user_plan_rs = $schema->resultset("UserPlan")->search( { user_id => $donor_id } );

        is ($user_plan_rs->count, 1, "donor has 1 plan");
        is ($user_plan_rs->find(stash "p2")->closed_at, undef, "current plan isnt closed yet");

        # Adicionando um novo plano.
        rest_post "/api/donor/$donor_id/plan",
            name  => "add plan again",
            stash => "p3",
            [ amount => fake_int(2001, 100000)->() ]
        ;

        is ( $user_plan_rs->count, 2, "donor has 2 plan now" );
        ok ( defined($user_plan_rs->find(stash "p2")->closed_at), "old plan closed");
        is ( $user_plan_rs->find(stash "p3")->closed_at, undef, "new plan ok" );

        die "rollback";
    };
};

done_testing();

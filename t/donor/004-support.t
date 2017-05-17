use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";

    db_transaction {
        diag "testando fluxo normal de libres";

        rest_post "/api/donor/$donor_id/plan",
            name  => "Creating a user plan",
            stash => "user_plan",
            [ amount => fake_int(20001, 100000)->() ],
        ;

        my $user_plan_id = stash "user_plan.id";

        rest_post "/api/journalist/$journalist_id/support",
            name => "donate to a journalist",
        ;

        # Não deve ser possível efetuar uma doação para um usuário que não seja um jornalista.
        rest_post "/api/journalist/$donor_id/support",
            name    => "donate to a donor --fail",
            is_fail => 1,
            code    => 404,
        ;
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
};

done_testing();

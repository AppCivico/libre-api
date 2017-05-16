use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $journalist_user_id = stash "journalist.id";
    my $donor_user_id      = stash "donor.id";

    rest_post "/api/donor/$donor_user_id/plan",
        name    => "Creating a user plan",
        code    => 200,
        stash   => "user_plan",
        params  => {
            amount => fake_int(20001, 100000)->(),
        }
    ;

    my $user_plan_id = stash "user_plan.id";

    rest_post "/api/journalist/$journalist_user_id/support",
        name => "donate to a journalist",
        code => 200,
    ;

    # Não deve ser possível efetuar uma doação para um usuário que não seja um jornalista.
    rest_post "/api/journalist/$donor_user_id/support",
        name    => "donate to a donor --fail",
        is_fail => 1,
        code    => 404,
    ;

    # Um libre/donation pode ou não estar associado a um plano
    rest_post "/api/journalist/$journalist_user_id/support",
        name => "donate to a journalist with user_plan",
        code => 200,
        params => {
            user_plan_id => $user_plan_id,
        }
    ;

};

done_testing();

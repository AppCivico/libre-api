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

    rest_post "/api/journalist/$journalist_user_id/donation",
        name => "donate to a journalist",
        code => 200,
    ;

    # Não deve ser possível efetuar uma doação para um usuário que não seja um jornalista.
    rest_post "/api/journalist/$donor_user_id/donation",
        name    => "donate to a donor --fail",
        is_fail => 1,
        code    => 404,
    ;
};

done_testing();

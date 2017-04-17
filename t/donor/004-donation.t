use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    
    create_journalist;
    api_auth_as user_id => stash "journalist.id";

    create_donor;
    api_auth_as user_id => stash "donor.id";
    
    my $journalist_user_id = stash "journalist.id";
    my $donor_user_id      = stash "donor.id";

    rest_post "/v1/user/$donor_user_id/donation",
        name    => "Doação",
        code    => 200,
        params  => {
            journalist_user_id  => $journalist_user_id,
        }
    ;

    rest_get "v1/user/$donor_user_id/donation",
        name  => "Listando doação de um doador",
        stash => "d1",
    ;

    # O id do donor não pode ser o mesmo do jornalista e vice-versa
    rest_post "/v1/user/$donor_user_id/donation",
        name    => "Doação invalida",
        is_fail => 1,
        params  => {
            journalist_user_id  => $donor_user_id,
        }
    ;

    # Apenas um doador pode fazer uma doação
    rest_post "/v1/user/$donor_user_id/donation",
        name    => "Doação",
        is_fail => 1,
        params  => {
            journalist_user_id  => $donor_user_id,
        }
    ;

};

done_testing();
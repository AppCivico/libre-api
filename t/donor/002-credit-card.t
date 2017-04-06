use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    rest_post "/v1/user/$donor_id/credit-card",
        name  => "get callback url",
        code  => 200,
        stash => "c1",
    ;

    # TODO Chamar o POST, que deve retornar uma url de callback.
    # TODO Essa url de callback deve ser chamada pelo front-end. Chamaremos ela no teste apenas para completar o fluxo.

};

done_testing();

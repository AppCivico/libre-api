use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {

    create_donor;
    api_auth_as user_id => stash "donor.id";
    
    my $donor_id = stash "donor.id";

    rest_post "/v1/donor/plan",
        name    => "Plano de um doador",
        code    => 200,
        params  => {
            amount => fake_int(30, 100)->(),
        }
    ;

};

done_testing();
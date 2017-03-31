use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    rest_post "/v1/register/donor",
        stash               => "r1",
        automatic_load_item => 0,
        params              => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
        },
    ;
};

done_testing();

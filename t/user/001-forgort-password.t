use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

db_transaction {
    create_donor{
        password => "libre123"
    };

    ok(my $user = $schema->resultset("User")->find(stash 'user.id'), 'test_name');
};

done_testing();


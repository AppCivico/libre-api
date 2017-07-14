use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    my $journalist_id = stash "journalist.id";
    api_auth_as user_id => $journalist_id;

    my $journalist = $schema->resultset("Journalist")->find($journalist_id);

    ok (!defined($journalist->customer_id), 'no customer id');
    ok (!defined($journalist->customer_key), 'no customer key');

    rest_get [ "api", "journalist", $journalist_id, "authlink" ],
        name  => "get authlink",
        stash => "authlink",
    ;

    stash_test "authlink" => sub {
        my $res = shift;

        is (ref($res->{picpayconnect}), "HASH", 'picpayconnect');
        ok (defined($res->{picpayconnect}->{authurl}), 'auth url');
    };

    ok ($journalist->discard_changes(), 'discard changes');
    ok (defined($journalist->customer_id), 'customer id');
    ok (defined($journalist->customer_key), 'customer key');
};

done_testing();

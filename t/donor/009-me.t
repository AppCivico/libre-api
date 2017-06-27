use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

db_transaction {
    create_donor(
        name    => "Junior",
        surname => "Moraes",
    );
    my $donor_id = stash "donor.id";

    rest_get "/api/donor/$donor_id",
        name    => "get when logged off --fail",
        is_fail => 1,
        code    => 403,
    ;

    api_auth_as user_id => stash "donor.id";
    rest_get "/api/donor/$donor_id",
        name  => "get donor",
        list  => 1,
        stash => "get_donor",
    ;

    stash_test "get_donor" => sub {
        my $res = shift;

        is ($res->{name}, "Junior");
        is ($res->{surname}, "Moraes");
    };

    # Editando o donor.
    rest_put [ "api", "donor", $donor_id ],
        name => "update donor",
        [
            name  => "Carlos",
            phone => "+5511980000000",
        ],
    ;

    rest_reload_list "get_donor";
    stash_test "get_donor.list" => sub {
        my $res = shift;

        is ($res->{name}, "Carlos", "name updated");
        is ($res->{phone}, "+5511980000000", "phone updated");
    };
};


done_testing();

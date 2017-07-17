use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
my $schema = Libre->model("DB");

db_transaction {
    create_journalist(
        name                     => "Lucas",
        surname                  => "Ansei",
        address_state            => "São Paulo",
        address_city             => "Taubaté",
        address_zipcode          => "12082-340",
        address_street           => "Rua Florival de Toledo",
        address_residence_number => "1"
    );

    my $journalist_id = stash "journalist.id";

    rest_get "/api/journalist/$journalist_id",
        name    => "get when logged off --fail",
        is_fail => 1,
        code    => 403,
    ;

    api_auth_as user_id => $journalist_id;
    rest_get "/api/journalist/$journalist_id",
        name  => "get journalist",
        list  => 1,
        stash => "get_journalist"
    ;

    stash_test "get_journalist" => sub {
        my $res = shift;

        is ($res->{id}, $journalist_id, 'id');
        is ($res->{name}, "Lucas", 'name');
        is ($res->{surname}, "Ansei", 'surname');
        is ($res->{address_city}, "Taubaté", 'address_city');
        is ($res->{address_state}, "São Paulo", 'address_state');
        is ($res->{address_street}, "Rua Florival de Toledo", 'address_street');
        is ($res->{address_residence_number}, "1", 'address_residence_number');
        is ($res->{is_authlinked}, 1, 'is authlinked');
    };

    rest_put "/api/journalist/$journalist_id",
        name => "update journalist",
        [
            surname      => "Da Silva",
            address_city => "Santos",
        ]
    ;

    rest_reload_list "get_journalist";

    stash_test "get_journalist.list" => sub {
        my $res = shift;

        is($res->{surname},      "Da Silva", "name updated");
        is($res->{address_city}, "Santos",   "city updated");
    };

    create_journalist;
    rest_get [ "api", "journalist", stash "journalist.id" ], name => "can't get other journalist", is_fail => 1, code => 403;
    rest_put [ "api", "journalist", stash "journalist.id" ],
        name    => "can't put other journalist",
        is_fail => 1,
        code    => 403,
        [ name => fake_name()->() ]
    ;
};

done_testing();

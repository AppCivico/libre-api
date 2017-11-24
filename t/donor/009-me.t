use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

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

        is( $res->{name},    'Junior' );
        is( $res->{surname}, 'Moraes' );
        is( $res->{has_active_cycle}, 0, 'has_active_cycle=0' );
        is( $res->{has_credit_card},  0, 'has_credit_card=0' );
        is( $res->{has_plan},         0, 'has_plan=0' );
    };

    # Editando o donor.
    rest_put [ "api", "donor", $donor_id ],
        name => "update donor", [
            name  => "Carlos",
            phone => "+5511980000000",
        ],
    ;

    # Mockando um cartão de crédito.
    ok (
        $schema->resultset("Donor")->find($donor_id)->update(
            {
                flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
                flotum_preferred_credit_card =>
'{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-01-01T00:00:00","id":"aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","mask":"1234*********567"}',
            }
        ),
        'fake credit card'
    );

    # Adicionando um plano pra testar a flag 'has_plan'.
    rest_post "/api/donor/$donor_id/plan",
        name   => "create first donor plan",
        stash  => "donor_plan",
        params => {
            amount => 2000,
        },
    ;

    rest_reload_list "get_donor";
    stash_test "get_donor.list" => sub {
        my $res = shift;

        is( $res->{name},  'Carlos',         'name=Carlos' );
        is( $res->{phone}, '+5511980000000', 'phone updated' );
        is( $res->{has_active_cycle}, 1, 'has_active_cycle=1' );
        is( $res->{has_credit_card},  1, 'has_credit_card=1' );
        is( $res->{has_plan},         1, 'has_plan=1' );
    };

    create_donor;
    rest_get [ "api", "donor", stash "donor.id" ], name => "can't get other donor", is_fail => 1, code => 403;
    rest_put [ "api", "donor", stash "donor.id" ],
        name    => "can't put other donor",
        is_fail => 1,
        code    => 403,
        [ name => fake_name()->() ]
    ;
};

done_testing();

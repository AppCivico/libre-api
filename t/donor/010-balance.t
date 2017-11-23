use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    ok( my $donor = $schema->resultset('Donor')->find($donor_id), 'get donor' );
    is( $donor->get_balance(), 0, 'balance=0' );

    # Mockando cartão de crédito para fazer a subscription no korduv.
    ok(
        $donor->update({
            flotum_id => "aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
            flotum_preferred_credit_card =>
'{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","mask":"5268*********853"}',
        }),
        'mock credit card'
    );

    # Criando um plano.
    rest_post "/api/donor/$donor_id/plan",
        name   => "create donor plan",
        stash  => "user_plan",
        params => {
            amount => 2000,
        },
    ;

    is( $donor->get_balance(), 2000, 'balance=2000' );

    my $plan_id = stash "user_plan.id";

    # Cancelando o plano.
    rest_post "/api/donor/$donor_id/plan/$plan_id/cancel",
        name => "cancel plan",
        code => 200,
    ;

    is( $donor->get_balance(), 0, 'balance=0' );
};

done_testing();

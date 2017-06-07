use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use HTTP::Request::Common qw(GET);

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    rest_post "/api/donor/$donor_id/plan",
        name   => "create donor plan",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    # Simulando o callback do korduv.
    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id});
    ok (my $callback_id = $user_plan->callback_id, "get callback_id");

    rest_post $Libre::Test::Further::korduv->{on_charge_attempted_failed},
        name    => "korduv callback --fail",
        code    => 200,
        headers => [ 'content-type' => "application/json" ],
        data    => encode_json({}),
    ;

    # TODO Testar se o email foi criado.

    is($schema->resultset("EmailQueue")->count, 1, 'email queued');
};

done_testing();

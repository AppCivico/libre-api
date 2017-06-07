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

    # Mockando cartão de crédito para fazer a subscription no korduv.
    ok (
        $schema->resultset("Donor")->find($donor_id)->update({
            flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
            flotum_preferred_credit_card =>
'"{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"3acd6d0c-58c0-40b9-9144-84a8b5f14806","mask":"5268*********853"}',
        }),
        'mock credit card'
    );

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

    is($schema->resultset("EmailQueue")->count, 1, 'email queued');
};

done_testing();

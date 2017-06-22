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
    my $donor = $schema->resultset("Donor")->find($donor_id);

    # Mockando cartão de crédito para fazer a subscription no korduv.
    ok (
        $donor->update({
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

    my $plan_id = stash "user_plan.id";
    ok (my $user_plan = $schema->resultset("UserPlan")->find($plan_id), "get user plan");
    ok ($user_plan->discard_changes(), 'discard changes');
    is ($user_plan->canceled, 0, "not canceled yet");
    is ($user_plan->canceled_at, undef, "canceled_at=undef");

    # Não deve ser possível criar um novo plano enquanto já houver um ativo. O usuário deve cancelar o plano vigente
    # antes de criar um novo.
    rest_post "/api/donor/$donor_id/plan",
        name    => "create donor plan --fail",
        is_fail => 1,
        code    => 400,
        [ amount => fake_int(2001, 100000)->() ],
    ;

    # Cancelando o plano.
    rest_post "/api/donor/$donor_id/plan/$plan_id/cancel",
        name => "cancel plan",
        code => 200,
    ;

    ok ($user_plan->discard_changes(), 'discard changes');
    ok ($user_plan->canceled, "plan canceled");
    ok (defined($user_plan->canceled_at), "canceled_at filled");

    is ($Libre::Test::Further::korduv->{cancel}, 1, "cancel on korduv");

    is ($donor->get_current_plan(), undef, "get_current_plan=undef");
    is ($user_plan->cancel_reason, "cancelled-by-user", "cancel_reason=cancelled-by-user");
};

done_testing();

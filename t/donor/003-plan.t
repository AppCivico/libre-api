use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";
    my $donor = $schema->resultset("Donor")->find($donor_id);

    rest_get "/api/donor/$donor_id/plan",
        name  => "list without plan",
        stash => "l1",
    ;

    is_deeply (
        (stash "l1")->{user_plan},
        [],
        "donor has no plan yet",
    );

    # O doador não pode escolher um valor de plano menor que 20
    rest_post "/api/donor/$donor_id/plan",
        name    => "Plano de um  doador",
        is_fail => 1,
        [
            amount => fake_int(-100, 1900)->()
        ],
    ;

    db_transaction {
        diag "fluxo básico de criação de plano.";

        rest_post "/api/donor/$donor_id/plan",
            name   => "Plano de um doador",
            stash  => "user_plan",
            params => {
                amount => fake_int(2001, 100000)->(),
            },
        ;

        rest_get "/api/donor/$donor_id/plan",
            name  => "Listando plano de um doador",
            stash => "l2",
        ;

        stash_test "l2" => sub {
            my $res = shift;

            is ($res->{user_plan}->[0]->{valid_until}, undef, "no valid until");
            is ($res->{user_plan}->[0]->{user_id}, $donor_id, "user id is donor id");
        };
    };

    db_transaction {
        diag "plan with credit card.";

        # Mockando cartão de crédito para fazer a subscription no korduv.
        ok (
            $donor->discard_changes->update({
                flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
                flotum_preferred_credit_card =>
'{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"3acd6d0c-58c0-40b9-9144-84a8b5f14806","mask":"5268*********853"}',
            }),
            'mock credit card'
        );

        rest_post "/api/donor/$donor_id/plan",
            name   => "add plan",
            stash  => "up2",
            params => {
                amount => fake_int(2001, 100000)->(),
            },
        ;

        # Neste ponto ele deve ter executado o método Libre::Schema::Result::update_on_korduv() e ter setado o
        # 'first_korduv_sync' para FALSE.
        ok (my $user_plan = $schema->resultset("UserPlan")->find(stash "up2.id"), "get user plan");
        ok (!$user_plan->first_korduv_sync, "first korduv sync=false");
    };

    db_transaction {
        diag "plan without credit card.";

        rest_post "/api/donor/$donor_id/plan",
            name   => "add plan",
            stash  => "up3",
            params => {
                amount => fake_int(2001, 100000)->(),
            },
        ;

        ok (my $user_plan = $schema->resultset("UserPlan")->find(stash "up3.id"), "get user plan");
        ok ($user_plan->first_korduv_sync, "first korduv sync=true");
        ok (!$user_plan->update_on_korduv(), 'update on korduv without credit card');
        ok ($user_plan->first_korduv_sync, "first korduv sync=true");

        $donor->discard_changes->update({
            flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
            flotum_preferred_credit_card =>
'{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"3acd6d0c-58c0-40b9-9144-84a8b5f14806","mask":"5268*********853"}',
        });

        ok ($user_plan->update_on_korduv(), 'update on korduv');
        ok (!$user_plan->discard_changes->first_korduv_sync, "first korduv sync=false");
    };

    db_transaction {
        diag "update the current plan.";

        ok (
            $donor->discard_changes->update({
                flotum_id => "587ef4d0-3316-4499-9f12-518a965248d7",
                flotum_preferred_credit_card =>
'{"validity":"201801","conjecture_brand":"mastercard","created_at":"2017-06-07T18:05:09","id":"3acd6d0c-58c0-40b9-9144-84a8b5f14806","mask":"5268*********853"}',
            }),
            'mock credit card'
        );

        rest_post "/api/donor/$donor_id/plan",
            name   => "add plan",
            stash  => "up4",
            params => {
                amount => 5000,
            },
        ;

        my $plan_id = stash "up4.id";
        ok (my $user_plan = $schema->resultset("UserPlan")->find($plan_id), "get user plan");
        ok (!$user_plan->first_korduv_sync, "first korduv sync=false");
        is ($user_plan->updated_at, undef, "no updated yet");

        rest_put "/api/donor/$donor_id/plan/$plan_id", name => "update plan", [ amount => 2000 ];

        ok ($user_plan->discard_changes, 'user_plan discard changes');

        is ($user_plan->amount, 2000, "amount updated");
        ok (!$user_plan->first_korduv_sync, "first korduv sync=false");
        ok (defined($user_plan->updated_at), "updated_at is set");
    };
};

done_testing();

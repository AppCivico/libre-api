use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use HTTP::Request::Common qw(GET);
use DateTime;
use DDP;

my $schema = Libre->model("DB");

db_transaction {
	create_donor;
    create_journalist;
	api_auth_as user_id => stash "donor.id";

    my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";
    my $libre_rs      = $schema->resultset("Libre");

    # Criando um plano
    rest_put "/api/donor/$donor_id/plan",
        name   => "creating donor plan",
        stash  => "user_plan",
        params => {
            amount => fake_int(2001, 100000)->(),
        },
    ;

    # Listando o plano
    rest_get "api/donor/$donor_id/plan",
        name  => "List a valid user plan",
        stash => "l1",
    ;

    # Verificando se o plano é válido
    stash_test "l1" => sub {
        my $res = shift;

        my $invalided_at          = $res->{user_plan}->[0]->{invalided_at};
        my $expected_invalided_at = undef;

        is($invalided_at , $expected_invalided_at, 'Valid user plan');
    };

    # Criando uma doação
    rest_post "/api/journalist/$journalist_id/support",
        name  => "donation",
        stash => "s1",
    ;

    # TODO verificar se o id do plan bate com o id do plan na doação

    my $user_plan = $schema->resultset("UserPlan")->find((stash("user_plan"))->{id});
    ok (my $callback_id = $user_plan->callback_id, "get callback_id");

    my $req = request GET "korduv/fail-forever/$callback_id";
    is ($req->status_line, "200 OK", "callback success");

    rest_get "api/donor/$donor_id/plan",
        name  => "List a user plan",
        stash => "l2",
    ;

    stash_test "l2" => sub {
        my $res = shift;

        my $invalided_at = $res->{user_plan}->[0]->{invalided_at};

        ok(defined($invalided_at), "User plan is invalid");
    };

    # TODO verificar se o user_plan das doações foram retirados
};

done_testing();
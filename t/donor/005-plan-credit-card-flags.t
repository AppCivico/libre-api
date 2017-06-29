use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $donor_id = stash "donor.id";

    # Listando um doador sem plano e sem cartão
    rest_get "/api/donor/$donor_id",
        name  => "list donor without both credit card and plan",
        stash => "l1",
    ;

    is ( (stash "l1")->{donor_has_plan}, 0, "no plan");
    is ( (stash "l1")->{donor_has_credit_card}, 0, "no credit card");

    # Listando um doador com um plano mas sem cartão
    rest_post "/api/donor/$donor_id/plan",
        name    => "Plano de um doador",
        [ amount => fake_int(2001, 100000)->() ],
    ;

    rest_get "/api/donor/$donor_id",
        name  => "list donor without both credit card and plan",
        stash => "l2",
    ;

    is ( (stash "l2")->{donor_has_plan}, 1, "has plan");
    is ( (stash "l2")->{donor_has_credit_card}, 0, "no credit card yet");

    # Adicionando um cartão para o donor
    $schema->resultset("Donor")->find($donor_id)->update({
        flotum_preferred_credit_card =>
'{"created_at":"2017-05-17T14:54:07","validity":"201801","conjecture_brand":"mastercard","mask":"5268*********853","id":"29efd2ae-6d3a-4247-b271-b9d2ba44596c"}',
    });

    rest_get "/api/donor/$donor_id",
        name  => "list donor without both credit card and plan",
        stash => "l3",
    ;

    is ( (stash "l3")->{donor_has_plan}, 1, "has plan");
    is ( (stash "l3")->{donor_has_credit_card}, 1, "has credit card");
};

done_testing();

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

    is_deeply(
        (stash "l1"),
        {
            donor_has_plan        => 0,
            donor_has_credit_card => 0,
        },
        "donor has no plan and credit card yet",
    );

    # TODO criar um plano para o donor e testar a resposta


    # TODO criar um cartão de crédito para o donor e testar a resposta
    


};

done_testing();
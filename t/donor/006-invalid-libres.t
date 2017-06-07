use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    api_auth_as user_id => stash "donor.id";

    my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";

    # Distribuindo 3 libres sem plano
    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s1",
    ;

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s2",
    ;

    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s3",
    ;

    # Alterando a data de criação de apenas 1 dos 3 libres distribuidos
    $schema->resultset("Libre")->find((stash("s1"))->{id})->update(
        { created_at => \"(NOW() - '$ENV{LIBRE_ORPHAN_EXPIRATION_TIME_DAYS} months'::interval)" }
    );

    # Invalidando os libres que devem ser invalidados
    $schema->resultset("Libre")->invalid_libres();

    # Testando se somente o like mais antigo está com invalid == true.
    my $invalided_lbr    = $schema->resultset("Libre")->find((stash("s1"))->{id});
    my $first_valid_lbr  = $schema->resultset("Libre")->find((stash("s2"))->{id});
    my $second_valid_lbr = $schema->resultset("Libre")->find((stash("s3"))->{id});

    is($invalided_lbr->invalid,    1, 'Libre invalid, as expected');
    is($first_valid_lbr->invalid,  0, 'Libre valid, as expected');
    is($second_valid_lbr->invalid, 0, 'Libre valid, as expected');
};

done_testing();

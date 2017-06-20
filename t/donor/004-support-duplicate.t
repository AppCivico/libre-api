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

    my $page_title   = fake_sentences(1)->();
    my $page_referer = fake_referer->();

    # Fazendo uma doação.
    rest_post "/api/journalist/$journalist_id/support",
        name  => "donate to a journalist",
        stash => "s1",
        [
            page_title   => $page_title,
            page_referer => $page_referer,
        ],
    ;

    # Se eu fizer uma doação com os mesmos dados, não deve ser contabilizada.
    rest_post "/api/journalist/$journalist_id/support",
        name  => "duplicated donation",
        stash => "s2",
        [
            page_title   => $page_title,
            page_referer => $page_referer,
        ],
    ;

    is (
        $schema->resultset("Libre")->search(
            {
                donor_id      => $donor_id,
                journalist_id => $journalist_id,
            },
        )->count,
        1,
        "no duplicated supports",
    );

    is_deeply ( stash "s1", stash "s2", "same libre_id" );

    # Mas se eu fizer uma doação diferente, deve contabilizar. Observe que, desta vez, o page_title e o page_referer
    # são diferentes dos apoios feitas acima.
    rest_post "/api/journalist/$journalist_id/support",
        name  => "duplicated donation",
        stash => "s3",
        params => fake_hash({
            page_title   => fake_sentences(1),
            page_referer => fake_referer,
        })->(),
    ;

    is (
        $schema->resultset("Libre")->search(
            {
                donor_id      => $donor_id,
                journalist_id => $journalist_id,
            },
        )->count,
        2,
        'two supports',
    );
    isnt ( (stash "s2")->{id}, (stash "s3")->{id}, "different supports" );
};

done_testing();

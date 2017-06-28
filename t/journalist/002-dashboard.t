use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use DateTime;

my $schema = Libre->model("DB");

db_transaction {
    create_journalist;
    create_donor;
    my $donor_id = stash "donor.id";
    api_auth_as user_id => $donor_id;

    my $journalist_id = stash "journalist.id";
    my $donor_id      = stash "donor.id";

    my $fake_title_first   = fake_sentences(1)->();
    my $fake_referer_first = fake_referer->();

    for ( 1 .. 10 ) {
        create_donor;
        api_auth_as user_id => stash "donor.id";
        rest_post "/api/journalist/$journalist_id/support",
            name  => "donating",
            [
                page_title   => $fake_title_first,
                page_referer => $fake_referer_first,
            ],
        ;
    }

    my $fake_title_second   = fake_sentences(1)->();
    my $fake_referer_second = fake_referer->();

    for ( 1 .. 3 ) {
        create_donor;
        api_auth_as user_id => stash "donor.id";
        rest_post "/api/journalist/$journalist_id/support",
            name  => "donating",
            stash => "s1",
            [
                page_title   => $fake_title_second,
                page_referer => $fake_referer_second,
            ],
        ;
    }

    # Mudando a data de criação do último apoio
    my $last_support         = $schema->resultset("Libre")->find(stash "s1");
    my $updated_last_support = $last_support->update({ created_at => \"(NOW() + '1 days'::interval)"});

    api_auth_as user_id => $journalist_id;
    rest_get "/api/journalist/$journalist_id/dashboard",
        stash => "l1",
    ;

    is(scalar(@{ stash "l1" }), 2, "two results");

    stash_test "l1" => sub {
        my $res = shift;

        my $last_created_at       = $res->[0]->{last_created_at};
        my $page_referer_fist     = $res->[0]->{page_referer};
        my $page_title_first      = $res->[0]->{page_title};
        my $times_supported_first = $res->[0]->{times_supported};

        my $page_referer_second    = $res->[1]->{page_referer};
        my $page_title_second      = $res->[1]->{page_title};
        my $times_supported_second = $res->[1]->{times_supported};

        ok(defined($last_created_at));

        ok(defined($page_referer_fist), 'first article referer');
        is($page_referer_fist, $fake_referer_first);

        ok(defined($page_title_first), 'first article title');
        is($page_title_first, $fake_title_first);

        ok(defined($times_supported_first), 'first article supports');
        is($times_supported_first, 10);

        ok(defined($page_referer_second), 'second article referer');
        is($page_referer_second, $fake_referer_second);

        ok(defined($page_title_second), 'second article title');
        is($page_title_second, $fake_title_second);

        ok(defined($times_supported_second), 'second article supports');
        is($times_supported_second, 3);
    };
};

done_testing();

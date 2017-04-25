use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    my @journalist_ids = ();
    my @donor_ids      = ();

    # Criarei dois doadores.
    for ( 1 .. 2 ) {
        create_donor;
        push @donor_ids, stash "donor.id";
    }

    # E dois jornalistas.
    for ( 1 .. 2 ) {
        create_journalist;
        push @journalist_ids, stash "journalist.id";
    }

    # Realizando doações.
    for my $donor_id (@donor_ids) {
        api_auth_as user_id => $donor_id;
        my $journalist_id = $journalist_ids[0];

        rest_post "/api/journalist/$journalist_id/donation",
            name    => "donate to a journalist",
            code    => 200,
        ;

        my $donor = $schema->resultset("Donor")->find($donor_id);
        #ok($donor->end_cycle(), "end cycle");
    }
};

done_testing();

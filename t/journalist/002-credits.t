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

    # Fechando o ciclo dos doadores.
    for my $donor_id (@donor_ids) {
        my $donor = $schema->resultset("Donor")->find($donor_id);
        ok($donor->end_cycle(), "end cycle");
    }
};

done_testing();

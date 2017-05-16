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
        ok ($schema->resultset("Donor")->find($donor_id)->end_cycle(), 'end cycle');
    }

    # Realizando algumas doações.
    # O doador 1 doará uma vez para o jornalista 1 e duas vezes para o jornalista 2. O doador 2 doará apenas uma vez
    # para o jornalista 1.
    api_auth_as user_id => $donor_ids[0];
    rest_post "/api/journalist/$journalist_ids[0]/support";
    rest_post "/api/journalist/$journalist_ids[1]/support";
    rest_post "/api/journalist/$journalist_ids[1]/support";

    api_auth_as user_id => $donor_ids[1];
    rest_post "/api/journalist/$journalist_ids[0]/support";

    # Fechando o ciclo agora que temos doações.
    for my $donor_id (@donor_ids) {
        ok ($schema->resultset("Donor")->find($donor_id)->end_cycle(), 'end cycle');
    }

    # Testando os créditos.
    is_deeply(
        [
            { donor_id => $donor_ids[0], journalist_id => $journalist_ids[0] },
            { donor_id => $donor_ids[0], journalist_id => $journalist_ids[1] },
            { donor_id => $donor_ids[0], journalist_id => $journalist_ids[1] },
            { donor_id => $donor_ids[1], journalist_id => $journalist_ids[0] },
        ],
        [
            map {
                my $r = $_;
                +{
                    map { $_ => $r->get_column($_) } qw/donor_id journalist_id/
                }
            } $schema->resultset("Credit")->search(
                { paid => "true" },
                {
                    'select' => [ qw/libre.donor_id libre.journalist_id/ ],
                    as       => [ qw/donor_id journalist_id/ ],
                    join     => "libre"
                }
            )->all(),
        ]
    );
};

done_testing();

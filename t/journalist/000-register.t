use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

db_transaction {
    # Registrando jornalista.
    create_journalist;

    #stash_test 'journalist.get', sub {
    #    my $me = @_;

    #    ok($me->{journalist}->{id} > 0, 'journalist id');
    #    is($me->{journalist}->{status}, "pending", 'journalist status pending');    
    #};

    # Não pode registrar jornalista sem RG, CPF e endereço
    my $email   = lc(fake_email()->());
    $email      =~ s/\s+/_/g;

    rest_post '/v1/register/journalist',
        name                => "Jornalista sem RG, CPF e endereço",
        is_fail             => 1,
        automatic_load_item => 0,
        params              => {
            email                   => $email,
            password                => "foobarpass",
            name                    => "Lucas",
            surname                 => "Ansei",
        },
    ;
};

done_testing();
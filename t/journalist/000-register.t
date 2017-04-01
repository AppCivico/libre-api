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

    
    my $email   = lc(fake_email()->());
    $email      =~ s/\s+/_/g;

    # Não pode registrar jornalista sem RG
    rest_post '/v1/register/journalist',
        name                => "Jornalista sem RG",
        is_fail             => 1,
        params              => {
            email                    => $email,
            password                 => "foobarpass",
            name                     => fake_name()->(),
            surname                  => "Foobarson",
            cpf                      => random_cpf(),
            address_state            => "Rio de Janeiro",
            address_city             => "Rio de Janeiro",
            address_zipcode          => '02351-000',
            address_street           => "Rua Flores do Piauí",
            address_residence_number => 1 + int(rand(2000)),
        },
    ;

    # O RG cadastrado deve ser válido
    rest_post '/v1/register/journalist',
        name                => "Jornalista com RG invalido",
        is_fail             => 1,
        params              => {
            email                    => $email,
            password                 => "foobarpass",
            name                     => fake_name()->(),
            surname                  => "Foobarson",
            rg                       => random_rg(0),
            cpf                      => random_cpf(),
            address_state            => "Rio de Janeiro",
            address_city             => "Rio de Janeiro",
            address_zipcode          => '02351-000',
            address_street           => "Rua Flores do Piauí",
            address_residence_number => 1 + int(rand(2000)),
        },
    ;

    # Não pode registrar jornalista sem CPF
    rest_post '/v1/register/journalist',
        name                => "Jornalista sem CPF",
        is_fail             => 1,
        params              => {
            email                    => $email,
            password                 => "foobarpass",
            name                     => fake_name()->(),
            surname                  => "foobarson",
            rg                       => random_rg(1),
            address_state            => "Rio de Janeiro",
            address_city             => "Rio de Janeiro",
            address_zipcode          => '02351-000',
            address_street           => "Rua Flores do Piauí",
            address_residence_number => 1 + int(rand(2000)),
        },
    ;

    # O CPF registrado deve ser válido
    rest_post '/v1/register/journalist',
        name                => "Jornalista com CPF invalido",
        is_fail             => 1,
        params              => {
            email                    => $email,
            password                 => "foobarpass",
            name                     => fake_name()->(),
            surname                  => "Foobarson",
            cpf                      => random_cpf(0),
            rg                       => random_rg(1),
            address_state            => "Rio de Janeiro",
            address_city             => "Rio de Janeiro",
            address_zipcode          => '02351-000',
            address_street           => "Rua Flores do Piauí",
            address_residence_number => 1 + int(rand(2000)),
        },
    ;

    # Não pode ser registrado um jornalista sem endereço
    rest_post '/v1/register/journalist',
        name                => "Jornalista sem endereço",
        is_fail             => 1,
        params              => {
            email                    => $email,
            password                 => "foobarpass",
            name                     => fake_name()->(),
            surname                  => "Foobarson",
            cpf                      => random_cpf(),
            rg                       => random_rg(1),
        },
    ;


    # Telefone deve ser opcional, mas não pode ser inválido.
    rest_post "/v1/register/journalist",
        automatic_load_item => 0,
        params              => {
            email               => fake_email()->(),
            password            => "fooquxbar1",
            name                => fake_first_name()->(),
            surname             => fake_surname()->(),
            cpf                      => random_cpf(),
            rg                       => random_rg(1),
            address_state            => "Rio de Janeiro",
            address_city             => "Rio de Janeiro",
            address_zipcode          => '02351-000',
            address_street           => "Rua Flores do Piauí",
            address_residence_number => 1 + int(rand(2000)),
            cellphone_number    => fake_digits("+551198#######")->(),
        },
    ;

    rest_post "/v1/register/journalist",
        is_fail => 1,
        params  => {
            email               => fake_email()->(),
            password            => "fooquxbar1",
            name                => fake_first_name()->(),
            surname             => fake_surname()->(),
            cellphone_number    => "+551398200 23",
        },
    ;
};

done_testing();
package Libre::Schema::ResultSet::Journalist;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

# Verificar roles
with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

# use Business::BR::CEP qw(teste_cep);
use Libre::Types qw(CPF EmailAddress);

use Data::Verifier;


sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                email   => {
                    required    => 1,
                    type        => EmailAddress,
                    filters     => [ qw(lower) ],
                    post_check  => sub {
                        my $r = shift;

                        $self->result_source->schema->resultset('User')->search({
                            email => $r->get_value('email'),
                        })->count and die \["email", "alredy exists"];

                        return 1;
                    }
                },
                password => {
                    required => 1,
                    type     => 'Str',
                },
                name => {
                    required    => 1,
                    type        => 'Str',
                    post_check  => sub {
                        my $name = $_[0]->get_value('name');

                        scalar(split(m{ }, $name)) > 1;
                    },
                },
                cpf => {
                    required    => 1,
                    type        => CPF,
                    post_check  => sub {
                        my $r = shift;

                        $self->search({
                            cpf => $r->get_value('cpf'),
                        })->count and die \["cpf", "alredy existis"];

                        return 1;
                    },
                },
                address_state => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $state = $r->get_value('address_state');
                        $self->result_source->schema->resultset('State')->search({ name => $state })->count;
                    },
                },
                address_city => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $city = $r->get_value('address_city');
                        $self->result_source->schema->resultset('City')->search({ name => $city })->count;
                    },
                },
                address_zipcode => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $r = shift;

                        my $cep = $r->get_value('address_zipcode');

                        # return test_cep($cep);
                        return $cep;
                    },
                },
                address_street => {
                    required   => 1,
                    type       => 'Str',
                },
                address_residence_number => {
                    required   => 1,
                    type       => 'Int',
                },
                address_complement => {
                    required   => 0,
                    type       => 'Str',
                },
                cellphone_number => {
                    required    => 0,
                    type        => 'Str',
                },
            },
        ),
    };
}

sub action_specs {
    my $self = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # Criando usuário
            my %user;
            $user{$_} = delete $values{$_} for qw(email password);

            $user{email} = $user{email};

            my $user = $self->result_source->schema->resultset('User')->create(\%user);
            # $user->add_to_roles({ id =>  });

            # Criando jornalista
            my $journalist = $user->journalist->create(\%values);

            return $journalist;
        },
    };
}

1;
package Libre::Schema::ResultSet::Journalist;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

# Verificar roles
with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

# use Business::BR::CEP qw(teste_cep);
use Libre::Types qw(CPF EmailAddress RG);

use Data::Verifier;
use Number::Phone::BR;


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
                },
                surname => {
                    required => 1,
                    type     => "Str",
                },
                cpf => {
                    required    => 1,
                    type        => CPF,
                    post_check  => sub {
                        my $r = shift;

                        $self->search({
                            cpf => $r->get_value('cpf'),
                        })->count and die \["cpf", "alredy exists"];

                        return 1;
                    },
                },
                rg  => {
                    required    => 1,
                    type        => RG,
                    post_check  => sub {
                        my $r = shift;

                        $self->search({
                            rg => $r->get_value('rg'),
                        })->count and die \["rg", "alredy exists"];

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
                    required   => 0,
                    type       => "Str",
                    post_check => sub {
                        my $phone = $_[0]->get_value("cellphone_number");
                        Number::Phone::BR->new($phone);
                    },
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my $user = $self->result_source->schema->resultset("User")->create({
                ( map { $_ => $values{$_} } qw(email password) ),
                verified    => 1,
                verified_at => \"now()",
            });

            $user->add_to_roles({ id => 2 });

            my $journalist = $self->create({
                ( map { $_ => $values{$_} } qw(name surname cpf rg address_state address_city address_zipcode address_street address_residence_number) ),
                user_id => $user->id,
            });

            return $journalist;
        },
    };
}

1;

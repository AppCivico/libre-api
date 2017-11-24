package Libre::Schema::ResultSet::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Libre::Role::Verification";
with 'Libre::Role::Verification::TransactionalActions::DBIC';

use Libre::Types qw/ EmailAddress PhoneNumber CPF PositiveInt /;

use Data::Verifier;
use Number::Phone::BR;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                email => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub {
                        my $email = $_[0]->get_value("email");
                        $self->result_source->schema->resultset("User")->search({ email => $email })->count == 0;
                    }
                },
                password => {
                    required => 1,
                    type     => "Str",
                },
                name => {
                    required => 1,
                    type     => "Str",
                },
                surname => {
                    required => 1,
                    type     => "Str",
                },
                phone => {
                    required => 0,
                    type     => PhoneNumber,
                },
                cpf => {
                    required => 1,
                    type     => CPF,
                },
                amount => {
                    required    => 0,
                    type        => PositiveInt,
                    post_check  => sub {
                        my $r = shift;

                        my $amount = $r->get_value('amount');

                        if ($amount < 2000 || $amount > 20000000) {
                            return 0;
                        }
                        return 1;
                    }
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

            if (length $values{password} < 6) {
                die \['password', "must have at least 6 characters"];
            }

            my $user = $self->result_source->schema->resultset('User')->create(
                {
                    ( map { $_ => $values{$_} } qw/ name surname email password / ),
                    verified    => 1,
                    verified_at => \"NOW()",
                }
            );

            $user->add_to_roles( { id => 3 } );

            $user->send_greetings_email();

            my $donor = $self->create(
                {
                    phone   => $values{phone},
                    cpf     => $values{cpf},
                    user_id => $user->id,
                }
            );

            if (defined($values{amount})) {
                my $user_plan = $user->user_plans->create( { amount => $values{amount} } );
                $user_plan->update_on_korduv();
            }

            return $donor;
        },
    };
}


1;

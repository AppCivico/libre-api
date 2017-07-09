package Libre::Schema::ResultSet::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Libre::Role::Verification";
with 'Libre::Role::Verification::TransactionalActions::DBIC';

use Libre::Types qw(EmailAddress PhoneNumber CPF);

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

            my $user = $self->result_source->schema->resultset("User")->create(
                {
                    ( map { $_ => $values{$_} } qw(name surname email password cpf) ),
                    verified    => 1,
                    verified_at => \"NOW()",
                }
            );

            $user->add_to_roles( { id => 3 } );

            return $self->create({
                ( map { $_ => $values{$_} } qw(phone) ),
                user_id => $user->id,
            });
        },
    };
}


1;

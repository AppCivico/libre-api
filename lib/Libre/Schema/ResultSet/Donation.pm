package Libre::Schema::ResultSet::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

# Verificar roles
with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                user_id  => {
                    required  => 1,
                    type      => "Int",
                    postcheck => sub {
                        my $user_id = $_[0]->get_value("user_id");
                        $self->result_source->schema->resultset("User")->search({ id => $user_id })->count;
                    }
                },
                journalist_id => {
                    required  => 1,
                    type      => "Int",
                    postcheck => sub {
                        my $journalist_id = $_[0]->get_value("journalist_id");
                        $self->result_source->schema->resultset("User")->search({ id => $journalist_id })->count;
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

            my $donation = $self->create({
                ( map { $_ => $values{$_} } qw(user_id journalist_id) ),                
                created_at  => \"now()",
            });

            return $donation;
        },
    };
}

1;
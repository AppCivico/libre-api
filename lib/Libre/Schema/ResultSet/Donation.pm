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
                created_at  => \"now()",
            });

            return $donation;
        },
    };
}

1;
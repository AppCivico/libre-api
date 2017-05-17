package Libre::Schema::ResultSet::Libre;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Libre::Role::Verification";
with "Libre::Role::Verification::TransactionalActions::DBIC";

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                donor_id => {
                    type       => "Int",
                    required   => 1,
                    post_check => sub {
                        my $donor_user_id = $_[0]->get_value("donor_id");

                        $self->result_source->schema->resultset("User")->find($donor_user_id)->is_donor();
                    },
                },
                journalist_id => {
                    type       => "Int",
                    required   => 1,
                    post_check => sub {
                        my $journalist_user_id = $_[0]->get_value("journalist_id");

                        $self->result_source->schema->resultset("User")->find($journalist_user_id)->is_journalist();
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

            my $support = $self->create(
                {
                    map { $_ => $values{$_} } qw(donor_id journalist_id),
                }
            );

            return $support;
        },
    };
}

1;

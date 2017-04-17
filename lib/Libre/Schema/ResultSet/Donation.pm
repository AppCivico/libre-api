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
                donor_user_id => {
                    required  => 1,
                    type      => "Int",
                    postcheck => sub {
                        my $donor_user_id = $_[0]->get_value("donor_user_id");
                        $self->result_source->schema->resultset("User")->search({ id => $donor_user_id })->count;
                    } 
                },
                journalist_user_id => {
                    required  => 1,
                    type      => "Int",
                    postcheck => sub {
                        my $journalist_user_id = $_[0]->get_value("journalist_user_id");

                        $self->result_source->schema->resultset("User")->search(
                        {
                            'me.id'     => $journalist_user_id,
                            'role.name' => "journalist",
                        },
                        {
                            join => { "user_roles" => "role" }
                        }
                        )->count;
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

            if ($values{'donor_user_id'} == $values{'journalist_user_id'}) {
                die \["donor_user_id", "equal to itself"];
            }

            my $donation = $self->create({
                ( map { $_ => $values{$_} } qw(donor_user_id journalist_user_id) ),           
                created_at  => \"now()",
            });

            return $donation;
        },
    };
}

1;
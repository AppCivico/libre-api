package Libre::Schema::ResultSet::UserPlan;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

# Verificar roles
with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Libre::Types qw(PositiveInt);

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                amount => {
                    required    => 1,
                    type        => PositiveInt,
                    post_check  => sub {
                        my $r = shift;

                        my $amount = $_[0]->get_value('amount');

                        if ($amount < 20) {
                            return 0;
                        }
                        else {
                            return 1;
                        }
                    }
                },
            }
        )
    }
}

sub action_specs {
    my $self = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my $user = $self->result_source->schema->resultset("User")->search({
                ( map { $_ => $values{$_} } qw(email password) ),
                verified    => 1,
                verified_at => \"now()",
            });

            $user->add_to_roles({ id => 3 });

            my $user_plan = $self->create({
                ( map { $_ => $values{$_} } qw(amount) ),
                user_id => $user->id,
            });

            return $user_plan;
        },
    };
}

1;
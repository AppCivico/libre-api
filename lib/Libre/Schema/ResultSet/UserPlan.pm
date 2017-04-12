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

                        my $amount = $r->get_value('amount');

                        if ($amount < 20) {
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

            my $user_plan = $self->create({
                amount      => $values{amount},
                created_at  => \"now()",
            });

            return $user_plan;
        },
    };
}

1;

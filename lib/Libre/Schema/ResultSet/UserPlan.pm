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
                user_id => {
                    required    => 1,
                    type        => "Int",
                    post_check  => sub {
                        my $r = shift;

                        my $user_id = $r->get_value('user_id');
                        $self->result_source->schema->resultset('User')->search({ id => $user_id })->count;
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
                ( map { $_ => $values{$_} } qw(amount user_id) ),                
                created_at  => \"now()",
                valid_until => \"(now() + '30 days'::interval)",
            });

            return $user_plan;
        },
    };
}

1;
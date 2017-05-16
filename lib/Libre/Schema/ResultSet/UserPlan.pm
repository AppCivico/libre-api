package Libre::Schema::ResultSet::UserPlan;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

BEGIN { $ENV{LIBRE_ORPHAN_EXPIRATION_TIME_DAYS} or die "missing env 'LIBRE_ORPHAN_EXPIRATION_TIME_DAYS'." }

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

            # TODO Avisar o Korduv que tenho um plano novo.
            # Fechando o plano anterior.
            $self->search( { closed_at => undef } )
            ->update( { closed_at => \"NOW()" } );

            my $user_plan = $self->create(
                {
                    amount      => $values{amount},
                    created_at  => \"NOW()",
                }
            );

            # Ao criar o plano, atrelamos todos os libres órfãos ao id desse plano. Os que são mais velhos que a env
            # 'LIBRE_ORPHAN_EXPIRATION_TIME_DAYS' permanecem como órfãos e nunca serão computados.
            my $orphan_expiration_time = int $ENV{LIBRE_ORPHAN_EXPIRATION_TIME_DAYS};

            # DBIx::Class, mas como isso vem do envfile.sh deixarei assim por enquanto.
            $user_plan->user->libre_donors
            ->search( \[ "created_at >= ( NOW() - '$orphan_expiration_time days'::interval )" ] )
            ->update( { user_plan_id => $user_plan->id } );

            return $user_plan;
        },
    };
}

1;

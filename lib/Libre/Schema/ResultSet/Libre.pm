package Libre::Schema::ResultSet::Libre;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Libre::Role::Verification";
with "Libre::Role::Verification::TransactionalActions::DBIC";

BEGIN {
    $ENV{LIBRE_MIN_AMOUNT}                  or die "missing env 'LIBRE_MIN_AMOUNT'.";
    $ENV{LIBRE_ORPHAN_EXPIRATION_TIME_DAYS} or die "missing env 'LIBRE_ORPHAN_EXPIRATION_TIME_DAYS'.";
}

use Data::Verifier;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                page_title => {
                    type     => "Str",
                    required => 1,
                },
                page_referer => {
                    type     => "Str",
                    required => 1,
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

            # Verificando se o doador possui um plano corrente.
            my $donor_id = $self->{attrs}->{where}->{donor_id} || $self->{attrs}->{where}->{'me.donor_id'};
            die "without 'donor_id'." unless $donor_id;

            my $donor = $self->result_source->schema->resultset("Donor")->find($donor_id);
            my $donor_plan = $donor->get_current_plan();

            # Verificando o limite mínimo do valor do libre.
            my $libre_min_amount = $ENV{LIBRE_MIN_AMOUNT};
            if ($donor->get_price_of_next_libre() < $libre_min_amount) {
                die \["support", "min libre price reached."];
            }

            my $support = $self->search(\%values)->next;
            $support ||= $self->create(
                {
                    ( map { $_ => $values{$_} } qw(page_title page_referer) ),
                    user_plan_id => $donor_plan ? $donor_plan->id : undef,
                }
            );

            return $support;
        },
    };
}

sub invalid_libres {
    my ($self) = @_;

    my $orphan_libre = $self->search(
        {
            created_at   => { "<" =>  \"(NOW() - '$ENV{LIBRE_ORPHAN_EXPIRATION_TIME_DAYS} day'::interval)"},
            user_plan_id => undef,
            invalid      => "false",
        }
    )->update(
        {
            invalid      => "true",
            invalided_at => \"NOW()",
        }
    );
}

sub is_valid {
    my ($self) = @_;

    return $self->search(
        {
            invalid     => "false",
            orphaned_at => undef,
        }
    );
}

1;

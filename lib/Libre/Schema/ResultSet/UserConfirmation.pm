package Libre::Schema::ResultSet::UserConfirmation;
use common::sense;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

use Libre::Types qw(EmailAddress);

use Data::Verifier;
use Time::HiRes;

sub verifiers_specs {
    my $self = shift;

    return {
        confirm => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                token => {
                    required => 1,
                    type     => "Str",
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        confirm => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my $token = $values{token};

            if (my $user_confirmation = $self->search(\%values)->next()) {
                my $user_id = $user_confirmation->user_id;

                $self->result_source->schema->resultset("User")->find($user_id)->update(
                    {
                        verified    => "true",
                        verified_at => \"NOW()",
                    },
                );
            }
        },
    };
}


1;

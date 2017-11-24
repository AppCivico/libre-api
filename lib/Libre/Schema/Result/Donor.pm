use utf8;
package Libre::Schema::Result::Donor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Donor

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<donor>

=cut

__PACKAGE__->table("donor");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 flotum_id

  data_type: 'text'
  is_nullable: 1

=head2 flotum_preferred_credit_card

  data_type: 'text'
  is_nullable: 1

=head2 cpf

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "flotum_id",
  { data_type => "text", is_nullable => 1 },
  "flotum_preferred_credit_card",
  { data_type => "text", is_nullable => 1 },
  "cpf",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<donor_cpf_key>

=over 4

=item * L</cpf>

=back

=cut

__PACKAGE__->add_unique_constraint("donor_cpf_key", ["cpf"]);

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Libre::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Libre::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-11 13:49:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dJ7HtN7udzqZRJy4XJ84Fg

use Libre::Utils;
use Libre::Types qw(EmailAddress PhoneNumber CPF);

use WebService::Korduv;

with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

has _korduv => (
    is         => "ro",
    isa        => "WebService::Korduv",
    lazy_build => 1,
);

sub verifiers_specs {
    my $self = shift;

    return {
        update => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                name => {
                    required => 0,
                    type     => "Str",
                },
                surname => {
                    required => 0,
                    type     => "Str",
                },
                phone => {
                    required => 0,
                    type     => PhoneNumber,
                },
                cpf => {
                    required => 0,
                    type     => CPF,
                },
            },
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        update => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my %user_params;
            defined($values{$_}) and $user_params{$_} = delete $values{$_} for qw/name surname/;

            $self->update(\%values);
            $self->user->update(\%user_params) if %user_params;
        },
    };
}

sub has_plan {
    my ($self) = @_;

    my $plan = $self->user->user_plans->search(
        {
            user_id      => $self->user_id,
            canceled     => 'false',
            invalided_at => undef,
        }
    )->next;

    if (ref $plan) {
        return 1;
    }
    return 0;
}

sub has_credit_card {
    my ($self) = @_;

    if ($self->flotum_preferred_credit_card) {
        return 1;
    }
    return 0;
}

=head2 get_current_plan()

Retorna o plano vigente do I<donor>.

=cut

sub get_current_plan {
    my ($self) = @_;

    return $self->user->user_plans->search(
        { canceled => "false", invalided_at => undef },
        {
            order_by  => { '-desc' => "created_at" },
            rows      => 1,
        }
    )
    ->next();
}

=head2 get_last_plan()

Retorna o último plano do doador, independente se ele foi cancelado ou não.

=cut

sub get_last_plan {
    my ($self) = @_;

    return $self->user->user_plans->search(
        {},
        {
            order_by  => { '-desc' => "created_at" },
            rows      => 1,
        }
    )
    ->next();
}

sub get_price_of_next_libre {
    my ($self) = @_;

    my $user_plan = $self->get_current_plan();

    my $user_plan_amount    = 2000;
    my $payment_gateway_tax = $ENV{LIBRE_TAX_PERCENTAGE};

    # Se o usuário possui um plano, obtenho o valor contratado. Caso não possua, assumo o valor mínimo de um plano e
    # a taxa corrente de taxa de gateway (que está setada na %ENV).
    if (ref $user_plan) {
        if (my $payment = $user_plan->get_last_payment()) {
            $user_plan_amount    = $payment->amount;
            $payment_gateway_tax = $payment->gateway_tax;
        }
    }

    # Tirando a porcentagem do libre do amount.
    my $libre_tax = ( $user_plan_amount * ( $payment_gateway_tax / 100 ) );
    my $amount_without_libre_tax = $user_plan_amount - $libre_tax;

    my $libres_count = $self->user->libre_donors
        ->is_valid
        ->search( { user_plan_id => ref($user_plan) ? [ $user_plan->id, undef ] : undef } )
        ->count
    || 1;

    $libres_count += 1;

    return int($amount_without_libre_tax / $libres_count);
}

sub get_balance {
    my ($self) = @_;

    my $user_plan = $self->get_last_plan();

    if (ref($user_plan)) {
        if ($user_plan->get_column('canceled')) {
            my $subscription = $self->get_korduv_subscription();

            if ($subscription->{status}->{status} eq 'active') {
                return $user_plan->get_column('amount');
            }
            else {
                my $last_payment_received_at = $subscription->{status}->{last_payment_received_at};
                my $payment_interval_value   = int($subscription->{subscription}->{payment_interval_value});

                my $is_current_cycle_payment = $self->result_source->schema->storage->dbh_do(sub {
                    $_[1]->selectrow_array("SELECT ( '$last_payment_received_at'::timestamp + '$payment_interval_value days'::interval ) > NOW()");
                });

                if ($is_current_cycle_payment) {
                    return $user_plan->get_column('amount');
                }
                else {
                    return 0;
                }
            }
        }
        else {
            return $user_plan->get_column('amount');
        }
    }
    return 0;
}

sub has_active_cycle {
    my ($self) = @_;

    my $balance = $self->get_balance();

    if ($balance > 0) {
        return 1;
    }
    return 0;
}

sub get_korduv_subscription {
    my ($self) = @_;

    return $self->_korduv->get_subscription(
        api_key => $ENV{LIBRE_KORDUV_API_KEY},
        remote_subscription_id => 'user:' . $self->get_column('user_id'),
    );
}

sub _build__korduv { WebService::Korduv->instance }

__PACKAGE__->meta->make_immutable;
1;

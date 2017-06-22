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
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-12 17:10:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MFuvND+lYdFDi0XHImqkvQ
use Libre::Utils;

use Data::Printer;

sub has_plan {
    my ($self) = @_;

    my $plan = $self->user->user_plans->search(
        {
            user_id      => $self->user_id,
            canceled     => 0,
            invalided_at => undef,
        }
    )->next;

    if ($plan) {
        return 1;
    }
    else {
        return 0;
    }
}

sub has_credit_card {
    my ($self) = @_;

    if ($self->flotum_preferred_credit_card) {
        return 1;
    }
    else {
        return 0;
    }
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

__PACKAGE__->meta->make_immutable;
1;

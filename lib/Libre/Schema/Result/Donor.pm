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

    if ($self->user->user_plans->search() >= 1) {
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


__PACKAGE__->meta->make_immutable;
1;

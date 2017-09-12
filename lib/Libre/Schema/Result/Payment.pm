use utf8;
package Libre::Schema::Result::Payment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Payment

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

=head1 TABLE: C<payment>

=cut

__PACKAGE__->table("payment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'payment_id_seq'

=head2 donor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 user_plan_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gateway_tax

  data_type: 'numeric'
  is_nullable: 0
  size: [4,2]

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "payment_id_seq",
  },
  "donor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "user_plan_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gateway_tax",
  { data_type => "numeric", is_nullable => 0, size => [4, 2] },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 donor

Type: belongs_to

Related object: L<Libre::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "donor",
  "Libre::Schema::Result::User",
  { id => "donor_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 money_transfers

Type: has_many

Related object: L<Libre::Schema::Result::MoneyTransfer>

=cut

__PACKAGE__->has_many(
  "money_transfers",
  "Libre::Schema::Result::MoneyTransfer",
  { "foreign.from_payment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_plan

Type: belongs_to

Related object: L<Libre::Schema::Result::UserPlan>

=cut

__PACKAGE__->belongs_to(
  "user_plan",
  "Libre::Schema::Result::UserPlan",
  { id => "user_plan_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-09-12 13:01:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:deTSgFd1/NXPteQuUPfEog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

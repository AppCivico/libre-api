use utf8;
package Libre::Schema::Result::MoneyTransfer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::MoneyTransfer

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

=head1 TABLE: C<money_transfer>

=cut

__PACKAGE__->table("money_transfer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'money_transfer_id_seq'

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 journalist_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 transferred

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 transferred_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "money_transfer_id_seq",
  },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "journalist_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "transferred",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "transferred_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 journalist

Type: belongs_to

Related object: L<Libre::Schema::Result::Journalist>

=cut

__PACKAGE__->belongs_to(
  "journalist",
  "Libre::Schema::Result::Journalist",
  { user_id => "journalist_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-06-01 18:05:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hNSLebuLv5jwi7N0MVselQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

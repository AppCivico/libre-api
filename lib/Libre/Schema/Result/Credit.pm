use utf8;
package Libre::Schema::Result::Credit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Credit

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

=head1 TABLE: C<credit>

=cut

__PACKAGE__->table("credit");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'credit_id_seq'

=head2 libre_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 paid

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 paid_at

  data_type: 'timestamp'
  is_nullable: 1

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
    sequence          => "credit_id_seq",
  },
  "libre_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "paid",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "paid_at",
  { data_type => "timestamp", is_nullable => 1 },
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

=head2 libre

Type: belongs_to

Related object: L<Libre::Schema::Result::Libre>

=cut

__PACKAGE__->belongs_to(
  "libre",
  "Libre::Schema::Result::Libre",
  { id => "libre_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-15 15:56:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E8C9Ef7vjRmZAzaot/w0Zg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

use utf8;
package Libre::Schema::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Donation

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

=head1 TABLE: C<donation>

=cut

__PACKAGE__->table("donation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'donation_id_seq'

=head2 created_at

  data_type: 'timestamp'
  is_nullable: 0

=head2 donor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 journalist_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "donation_id_seq",
  },
  "created_at",
  { data_type => "timestamp", is_nullable => 0 },
  "donor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "journalist_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 credits

Type: has_many

Related object: L<Libre::Schema::Result::Credit>

=cut

__PACKAGE__->has_many(
  "credits",
  "Libre::Schema::Result::Credit",
  { "foreign.donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 journalist

Type: belongs_to

Related object: L<Libre::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "journalist",
  "Libre::Schema::Result::User",
  { id => "journalist_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-25 16:31:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cH5kXUlXWyeOVK60AedMjA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

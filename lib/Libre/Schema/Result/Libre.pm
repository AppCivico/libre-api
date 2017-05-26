use utf8;
package Libre::Schema::Result::Libre;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Libre

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

=head1 TABLE: C<libre>

=cut

__PACKAGE__->table("libre");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'libre_id_seq'

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 donor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 journalist_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_plan_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 invalided_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 invalid

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "libre_id_seq",
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "donor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "journalist_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_plan_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "invalided_at",
  { data_type => "timestamp", is_nullable => 1 },
  "invalid",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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
  { "foreign.libre_id" => "self.id" },
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

=head2 user_plan

Type: belongs_to

Related object: L<Libre::Schema::Result::UserPlan>

=cut

__PACKAGE__->belongs_to(
  "user_plan",
  "Libre::Schema::Result::UserPlan",
  { id => "user_plan_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-26 14:05:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IMH1QDiXFzX3NUUJ3VYEMQ


__PACKAGE__->meta->make_immutable;
1;

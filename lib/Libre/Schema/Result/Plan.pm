use utf8;
package Libre::Schema::Result::Plan;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Plan

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

=head1 TABLE: C<plan>

=cut

__PACKAGE__->table("plan");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'plan_id_seq'

=head2 value

  data_type: 'numeric'
  is_nullable: 0
  size: [8,2]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "plan_id_seq",
  },
  "value",
  { data_type => "numeric", is_nullable => 0, size => [8, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<plan_value_key>

=over 4

=item * L</value>

=back

=cut

__PACKAGE__->add_unique_constraint("plan_value_key", ["value"]);

=head1 RELATIONS

=head2 user_plans

Type: has_many

Related object: L<Libre::Schema::Result::UserPlan>

=cut

__PACKAGE__->has_many(
  "user_plans",
  "Libre::Schema::Result::UserPlan",
  { "foreign.plan" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-06 11:57:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pCLLOI7ji07I/TjT5dC7Sw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

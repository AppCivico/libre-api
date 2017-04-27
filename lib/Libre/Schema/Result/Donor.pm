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

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 surname

  data_type: 'text'
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
  "name",
  { data_type => "text", is_nullable => 0 },
  "surname",
  { data_type => "text", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-17 11:21:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mKj1VBDK4mU/lYaHqWC8pw
use Libre::Utils;

use Data::Printer;

sub end_cycle {
    my ($self) = @_;

    my $dbh = $self->result_source->schema->storage->dbh();

    $dbh->do(<<'SQL_QUERY', undef, $self->id, $self->id);
WITH credit_tmp AS (
  SELECT id
  FROM donation
  WHERE donor_id = ?
    AND id NOT IN (
      SELECT c.id
      FROM credit c
      JOIN donation d
        ON c.donation_id = d.id
      WHERE d.donor_id = ?
    )
)
INSERT INTO credit (donation_id, paid, paid_at) SELECT id, 'TRUE', now() FROM credit_tmp ;
SQL_QUERY

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

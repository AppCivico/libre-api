use utf8;
package Libre::Schema::Result::UserBankAccount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::UserBankAccount

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

=head1 TABLE: C<user_bank_account>

=cut

__PACKAGE__->table("user_bank_account");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_bank_account_id_seq'

=head2 bank_institution_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 agency

  data_type: 'text'
  is_nullable: 0

=head2 account

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_bank_account_id_seq",
  },
  "bank_institution_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "agency",
  { data_type => "text", is_nullable => 0 },
  "account",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 bank_institution

Type: belongs_to

Related object: L<Libre::Schema::Result::BankInstitution>

=cut

__PACKAGE__->belongs_to(
  "bank_institution",
  "Libre::Schema::Result::BankInstitution",
  { id => "bank_institution_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 journalists

Type: has_many

Related object: L<Libre::Schema::Result::Journalist>

=cut

__PACKAGE__->has_many(
  "journalists",
  "Libre::Schema::Result::Journalist",
  { "foreign.user_bank_account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-30 14:29:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:taIk+67hfhBRNvkCKnjnNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

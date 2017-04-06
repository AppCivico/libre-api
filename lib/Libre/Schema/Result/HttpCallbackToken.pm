use utf8;
package Libre::Schema::Result::HttpCallbackToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::HttpCallbackToken

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

=head1 TABLE: C<http_callback_token>

=cut

__PACKAGE__->table("http_callback_token");

=head1 ACCESSORS

=head2 token

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 action

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 extra_args

  data_type: 'json'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 executed_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "token",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "action",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "extra_args",
  { data_type => "json", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "executed_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</token>

=back

=cut

__PACKAGE__->set_primary_key("token");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-04 17:28:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GT5HWHMaDs+aWEa6DYsJgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

use utf8;
package Libre::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_id_seq'

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 verified

  data_type: 'boolean'
  is_nullable: 0

=head2 verified_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "email",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "verified",
  { data_type => "boolean", is_nullable => 0 },
  "verified_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("user_email_key", ["email"]);

=head1 RELATIONS

=head2 donors

Type: has_many

Related object: L<Libre::Schema::Result::Donor>

=cut

__PACKAGE__->has_many(
  "donors",
  "Libre::Schema::Result::Donor",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 journalists

Type: has_many

Related object: L<Libre::Schema::Result::Journalist>

=cut

__PACKAGE__->has_many(
  "journalists",
  "Libre::Schema::Result::Journalist",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<Libre::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Libre::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_sessions

Type: has_many

Related object: L<Libre::Schema::Result::UserSession>

=cut

__PACKAGE__->has_many(
  "user_sessions",
  "Libre::Schema::Result::UserSession",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-04 10:13:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7/QHjbNticv6quyFOLhdsg
__PACKAGE__->remove_column("password");
__PACKAGE__->add_column(
    password => {
        data_type        => "text",
        passphrase       => 'crypt',
        passphrase_class => "BlowfishCrypt",
        passphrase_args  => {
            cost        => 8,
            salt_random => 1,
        },
        passphrase_check_method => "check_password",
        is_nullable             => 0,
    },
);

use Libre::Utils;

sub new_session {
    my ($self, %args) = @_;

    my $schema = $self->result_source->schema;

    my $session = $schema->resultset('UserSession')->search({
        user_id      => $self->id,
        valid_until  => { '>=' => \"NOW()" },
    })->next;

    if (!defined($session)) {
        $session = $self->user_sessions->create({
            api_key      => random_string(128),
            valid_until  => \"(NOW() + '1 days'::interval)",
        });
    }

    return {
        user_id => $self->id,
        roles   => [ map { $_->name } $self->roles ],
        api_key => $session->api_key,
    };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

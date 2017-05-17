use utf8;
package Libre::Schema::Result::UserPlan;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::UserPlan

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

=head1 TABLE: C<user_plan>

=cut

__PACKAGE__->table("user_plan");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_plan_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 valid_until

  data_type: 'timestamp'
  is_nullable: 1

=head2 canceled_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_plan_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "valid_until",
  { data_type => "timestamp", is_nullable => 1 },
  "canceled_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 libres

Type: has_many

Related object: L<Libre::Schema::Result::Libre>

=cut

__PACKAGE__->has_many(
  "libres",
  "Libre::Schema::Result::Libre",
  { "foreign.user_plan_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-17 16:38:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0M0+Apok4ek3RrA8oOiF/A

BEGIN { $ENV{LIBRE_KORDUV_API_KEY} or die "missing env 'LIBRE_KORDUV_API_KEY'." }

use WebService::Korduv;

has _korduv => (
    is         => "ro",
    isa        => "WebService::Korduv",
    lazy_build => 1,
);

sub update_on_korduv {
    my ($self) = @_;

    return $self->_korduv->setup_subscription(
        api_key => $ENV{LIBRE_KORDUV_API_KEY},

        payment_interval_class => "each_n_days",
        payment_interval_value => 30,

        remote_subscription_id => 0,

        currency       => "bra",
        pricing_schema => "linear",

        base_price  => $self->amount,
        extra_price => 0,
        extra_usage => 0,

        fail_forever_after    => 3,
        fail_forever_interval => 86400,

        timezone    => "America/Sao_Paulo",
        charge_time => "09:00",
    );
}

sub _build__korduv { WebService::Korduv->instance }

__PACKAGE__->meta->make_immutable;
1;

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

=head2 callback_id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 last_close_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 invalided_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

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
  "callback_id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "last_close_at",
  { data_type => "timestamp", is_nullable => 1 },
  "invalided_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-19 21:51:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QGaCpWqbl7nws1LowsFc5w

BEGIN { $ENV{LIBRE_KORDUV_API_KEY} or die "missing env 'LIBRE_KORDUV_API_KEY'." }

use WebService::Korduv;
use WebService::HttpCallback;
use Libre::Utils;

has _httpcb => (
    is         => "ro",
    isa        => "WebService::HttpCallback",
    lazy_build => 1,
);

has _korduv => (
    is         => "ro",
    isa        => "WebService::Korduv",
    lazy_build => 1,
);

sub update_on_korduv {
    my ($self) = @_;

    # Discard changes para obter o callback_url.
    my $callback_id = $self->discard_changes->callback_id;

    return $self->_korduv->setup_subscription(
        api_key => $ENV{LIBRE_KORDUV_API_KEY},

        payment_interval_class => "each_n_days",
        payment_interval_value => 30,

        remote_subscription_id => $self->user->id,

        currency       => "bra",
        pricing_schema => "linear",

        on_charge_renewed          => get_libre_api_url_for('/korduv/success-renewal/' . $callback_id ),
        on_charge_failed_forever   => get_libre_api_url_for('/korduv/success-failed/'  . $callback_id ),
        on_charge_attempted_failed => get_libre_api_url_for('/korduv/success-failed/'  . $callback_id ),

        base_price  => $self->amount,
        extra_price => 0,
        extra_usage => 0,

        fail_forever_after    => 3,
        fail_forever_interval => 86400,

        timezone    => "America/Sao_Paulo",
        charge_time => "09:00",
    );
}

sub on_korduv_callback_success {
    my ($self, $data) = @_;

    # TODO Criar um novo http callback para daqui $DAYS_BETWEEN_PAYMENTS.
    my $httpcb_rs = $self->result_source->schema->resultset("HttpCallbackToken");
    my $token = $httpcb_rs->create_for_action("payment-success-renewal");

    # TODO Na query devemos usar a data do korduv, e não NOW().
    my $wait_until = $self->result_source->schema->resultset("UserPlan")->search(
        { id => $self->id },
        {
            select => [
                \<<'SQL_QUERY'
EXTRACT(
  EPOCH FROM (
    CASE WHEN last_close_at IS NULL THEN (
      NOW() + '30 days'::interval
    )
    ELSE (
      last_close_at + '30 days'::interval
    )
    END
  )
)
SQL_QUERY
            ],
            'as' => [ "wait_until_epoch", ]
        }
    )->next;

    # Agendando o callback.
    $self->_httpcb->add(
        url        => get_libre_api_url_for("/callback-for-token/" . $token),
        method     => "get",
        wait_until => $wait_until->get_column("wait_until_epoch"),
    );
}

sub on_korduv_fail_forever {
    my ($self) = @_;

    my $httpcb_rs = $self->result_source->schema->resultset("HttpCallbackToken");
    my $token     = $httpcb_rs->create_for_action("payment-fail-forever");

    my $plan = $self->result_source->schema->resultset("UserPlan")->find($self->id)->update(
        { invalided_at => \"NOW()"}
    );
}

sub _build__korduv { WebService::Korduv->instance }

sub _build__httpcb { WebService::HttpCallback->instance }

__PACKAGE__->meta->make_immutable;
1;

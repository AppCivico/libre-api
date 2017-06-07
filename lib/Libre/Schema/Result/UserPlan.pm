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

=head2 payments

Type: has_many

Related object: L<Libre::Schema::Result::Payment>

=cut

__PACKAGE__->has_many(
  "payments",
  "Libre::Schema::Result::Payment",
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-05-23 15:29:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vxUf/ggAJ+7SWz14Jue8fw

BEGIN {
    $ENV{LIBRE_KORDUV_API_KEY}        or die "missing env 'LIBRE_KORDUV_API_KEY'.";
    $ENV{LIBRE_DAYS_BETWEEN_PAYMENTS} or die "missing env 'LIBRE_DAYS_BETWEEN_PAYMENTS'.";
    $ENV{LIBRE_TAX_PERCENTAGE}        or die "missing env 'LIBRE_TAX_PERCENTAGE'.";
}

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
    my ($self, %opts) = @_;

    # Discard changes para obter o callback_url.
    my $callback_id = $self->discard_changes->callback_id;
    my $user_id = $self->user->id;

    return $self->_korduv->setup_subscription(
        api_key => $ENV{LIBRE_KORDUV_API_KEY},

        payment_interval_class => "each_n_days",
        payment_interval_value => 30,

        remote_subscription_id => "user:$user_id",

        currency       => "bra",
        pricing_schema => "linear",

        on_charge_renewed          => get_libre_api_url_for('/korduv/success-renewal/' . $callback_id ),
        on_charge_failed_forever   => get_libre_api_url_for('/korduv/fail-forever/'    . $callback_id ),
        on_charge_attempted_failed => get_libre_api_url_for('/korduv/fail/'            . $callback_id ),

        base_price  => $self->amount,
        extra_price => 0,
        extra_usage => 0,

        fail_forever_after    => 3,
        fail_forever_interval => 86400,

        timezone    => "America/Sao_Paulo",
        charge_time => "09:00",

        %opts,
    );
}

sub on_korduv_callback_success {
    my ($self, $data) = @_;

    $self->result_source->schema->txn_do(sub {
        die "invalid request" unless ref($data) eq "HASH" && defined($data->{last_subscription_charge});

        my $amount = $data->{last_subscription_charge}->{charge_amount};

        # Criando o registro na tabela payment.
        my $payment = $self->user->payments->create(
            {
                donor_id     => $self->user_id,
                amount       => $amount,
                user_plan_id => $self->id,
                gateway_tax  => $ENV{LIBRE_TAX_PERCENTAGE},
            }
        );

        my $httpcb_rs = $self->result_source->schema->resultset("HttpCallbackToken");
        my $token = $httpcb_rs->create_for_action(
            "payment-success-renewal",
            {
                user_id      => $self->user->id,
                user_plan_id => $self->id,
                payment_id   => $payment->id,
            }
        );

        my $last_payment_received_at = $data->{status}->{last_payment_received_at};
        if (!defined($last_payment_received_at)) {
            die "missing 'last_payment_received_at'.";
        }

        my $days_between_payments = int($ENV{LIBRE_DAYS_BETWEEN_PAYMENTS});

        my $wait_until = $self->result_source->schema->resultset("UserPlan")->search(
            { id => $self->id },
            {
                select => [
                    \[<<"SQL_QUERY", "${days_between_payments} days", $last_payment_received_at,
EXTRACT(
  EPOCH FROM (
    ?::interval + (
      CASE WHEN last_close_at IS NULL THEN ( ? )
      ELSE ( last_close_at )
      END
    )
  )
)
SQL_QUERY
                    ]
                ],
                'as' => [ "wait_until_epoch", ]
            }
        )->next;

        # Agendando o callback.
        $self->_httpcb->add(
            url        => get_libre_api_url_for("/callback-for-token/" . $token),
            method     => "post",
            wait_until => $wait_until->get_column("wait_until_epoch"),
        );
    });
}

sub on_korduv_callback_fail {
    my ($self) = @_;

    my $email_queue_rs = $self->result_source->schema->resultset("EmailQueue");

    my $email = Libre::Mailer::Template->new(
        to       => $self->user->email,
        from     => 'no-reply@libre.org.br',
        subject  => "Libre - Seu pagamento não foi bem sucedido",
        template => get_data_section('payment-fail.tt'),
        vars     => {
            name => $self->user->name,
        },
    )->build_email();

    my $queued = $email_queue_rs->create({ body => $email->as_string });
    
    return $queued;
}

sub on_korduv_fail_forever {
    my ($self) = @_;

    $self->update( { invalided_at => \"NOW()" } );

    my $libres_rs     = $self->result_source->schema->resultset("Libre");
    my $orphan_libres = $libres_rs->search(
        { 
            "user_plan.invalided_at" => \"IS NOT NULL",
            donor_id                 => $self->user_id,
        },
        {
            join => "user_plan",
        }
    )->update(
        { user_plan_id => undef }
    );
}

sub _build__korduv { WebService::Korduv->instance }

sub _build__httpcb { WebService::HttpCallback->instance }

__PACKAGE__->meta->make_immutable;
1;

__DATA__

@@ payment-fail.tt

<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
    </head>
    <body>
        <div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                <tbody>
                    <tr>
                        <td>
                            <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
                                <tbody>
                                    <tr>
                                        <td height="50"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2"><a href="midialibre.com.br"><img src="http://imgur.com/a/vTl7s" class="x_deviceWidth" style="border-radius:7px 7px 0 0; float:left"></a></td>
                                    </tr>
                                    <tr>
                                        <td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
                                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
                                                <tbody>
                                                    <tr>
                                                        <td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
                                                            <p><span><b>Olá [% name %], </b><br>
                                                                <br></span>
                                                            </p>
                                                            <p> <strong> </strong>Recebemos a sinalização de que o seu pagamento falhou.<br><br>O pagamento tentará ser realizado novamente. Após 3 falhas o pagamento deverá ser realizado novamente manualmente.
                                                            </p>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td height="30"></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
                                                            <strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
                                                    
                                                                <p>Dúvidas? Acesse <a href="https://www.midialibre.com.br/faq" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
                                                                Equipe Libre
                                                            </strong>
                                                            <a href="mailto:contato@midialibre.com.br" target="_blank" style="color:#4ab957"></a>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td height="30"></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
                                <tbody>
                                    <tr>
                                        <td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
                                            <span><strong>Libre</strong></span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        </div>
        </div></div>
    </body>
</html>

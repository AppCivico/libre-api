package WebService::Korduv;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;
use Libre::Utils;

BEGIN { $ENV{LIBRE_KORDUV_URL} or die "missing env 'LIBRE_KORDUV_URL'." }

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new }

sub setup_subscription {
    my ( $self, %opts ) = @_;

    if (is_test()) {
        $Libre::Test::Further::korduv = \%opts;

        return {
            status       => { xxxxxxxxxx => rand(10000), },
            subscription => \%opts
        };

    }
    else {
        my $res;
        eval {
            retry {
                $res = $self->furl->put( $ENV{LIBRE_KORDUV_URL} . '/subscriptions', [], [%opts] );
                die $res->decoded_content unless $res->is_success;
            }
            retry_if { shift() < 3 } catch { die $_; };
        };

        die "Error: $@" if $@;
        die "Cannot call http callback" unless $res;
        die "Request failed: " . $res->as_string unless $res->is_success;

        return decode_json( $res->decoded_content );
    }
}

sub get_subscription {
    my ($self, %opts) = @_;

    if (is_test()) {
        return {
            status => {
                cancel_reason => "cancelled-by-user",
                paid_until    => "2017-10-10 12:00:00",
                status        => "cancelled",
                locked        => 0,
                last_charge_created_at => "2017-01-01 00:00:00.309233",
                next_billing_at => undef,
                cancelled_at    => undef,
                last_payment_received_at => "2017-01-01 00:00:00.374811",
                last_subscription_charge => {
                    id => 1,
                    charge_amount => 2000,
                    charge_id     => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                    charge_created_at => "2017-01-01 12:35:23.309233",
                },
            },
            subscription => {
                currency   => "brl",
                created_at =>  "2017-08-11T18:00:10",
                on_charge_renewed  => "http://localhost/korduv/renewed",
                flotum_customer_id => "aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
                merchant_id => 1,
                timezone    => "America/Sao_Paulo",
                extra_price => undef,
                on_charge_attempted_failed => "http://localhost/korduv/failed",
                payment_interval_class   => "each_n_days",
                minimum_charge_action    => "drop",
                fail_forever_interval    => 86400,
                flotum_credit_card_id    => "aaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
                on_charge_failed_forever => "http://localhost/korduv/fail-forever",
                fail_forever_after => 3,
                extra_usage        => undef,
                base_price         => 2000,
                charge_time        => "09:00:00",
                minimum_charge_amount => 100,
                merchant_payment_account_id => 1,
                payment_interval_value => 30,
                remote_subscription_id => "user:1",
                pricing_schema         => "linear",
            }
        };
    }

    my $res;
    eval {
        retry {
            $res = $self->furl->get(
                $ENV{LIBRE_KORDUV_URL}
                . '/subscriptions?'
                . join( '&', map { $_ . '=' . $opts{$_} } keys %opts )
            );
            die $res->decoded_content unless $res->is_success;
        }
        retry_if { shift() < 3 } catch { die $_ };
    };

    die "Error: $@" if $@;
    die "Cannot call http callback" unless $res;
    die "Request failed: " . $res->as_string unless $res->is_success;

    return decode_json( $res->decoded_content );
}

1;


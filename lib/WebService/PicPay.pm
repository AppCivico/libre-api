package WebService::PicPay;
use common::sense;
use MooseX::Singleton;

use Furl;
use Try::Tiny::Retry;
use JSON::MaybeXS;
use Libre::Utils;

BEGIN {
    $ENV{LIBRE_PICPAY_CLIENT_ID} or die "missing env 'LIBRE_PICPAY_CLIENT_ID'.";
    $ENV{LIBRE_PICPAY_API_KEY}   or die "missing env 'LIBRE_PICPAY_API_KEY'.";
}

has furl => (
    is         => "rw",
    isa        => "Furl",
    lazy_build => 1,
);

has _endpoint => (
    is      => "ro",
    reader  => "endpoint",
    default => "https://connect.picpay.com/v1",
);

sub register {
    my ($self) = @_;

    if (is_test()) {
        return {
            customer => {
                customer_key => "6a0378e4-5cff-469f-ac90-69c51807d9cc",
                id           => "cus_vs65ueYFV32WEZ26960dbb",
            },
        }
    }

    my $res = $self->furl->get(
        $self->endpoint . "/register",
        [
            api_key   => $ENV{LIBRE_PICPAY_API_KEY},
            client_id => $ENV{LIBRE_PICPAY_CLIENT_ID},
        ],
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub authlink {
    my ($self, %opts) = @_;

    if (is_test()) {
        return {
            picpayconnect => {
                authurl => "https://picpay.com/connect/authUser?1f4dee7a-b33a-452c-2c83-dbcf5f1adab3",
            }
        };
    }

    my $res = $self->furl->get(
        $self->endpoint . "/authlink",
        [
            api_key   => $ENV{LIBRE_PICPAY_API_KEY},
            client_id => $ENV{LIBRE_PICPAY_CLIENT_ID},
            %opts,
        ],
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub _build_furl { Furl->new }

1;


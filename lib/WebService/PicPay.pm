package WebService::PicPay;
use common::sense;
use MooseX::Singleton;

use Furl;
use HTTP::Request;
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

has _client_id => (
    is       => "rw",
    isa      => "Str",
    required => 1,
    default  => $ENV{LIBRE_PICPAY_CLIENT_ID},
);

has _api_key => (
    is       => "rw",
    isa      => "Str",
    required => 1,
    default  => $ENV{LIBRE_PICPAY_API_KEY},
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
            'Content-Type' => "application/json",
            api_key   => $self->_api_key,
            client_id => $self->_client_id,
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
            %opts,
            'Content-Type' => "application/json",
            api_key   => $self->_api_key,
            client_id => $self->_client_id,
        ],
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub userdata {
    my ($self, %opts) = @_;

    if (is_test()) {
        return {
            picpayuser => {
                name           => "Junior Moraes",
                picture_url    => undef,
                wallet_balance => 238,
            },
        };
    }

    my $customer_key = delete $opts{customer_key};

    my $res = $self->furl->get(
        $self->endpoint . "/picpayuserdata",
        [
            'Content-Type' => "application/json",
            api_key      => $self->_api_key,
            client_id    => $self->_client_id,
            customer_key => $customer_key,
        ],
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub customer {
    my ($self, %opts) = @_;

    if (is_test()) {
        return {
            customer => {
                birth_date              =>  undef,
                cellphone_number        =>  "+5511988713483",
                cpf                     =>  75511600350,
                email                   =>  'rose.garza@quosquis.com',
                id                      =>  "cus_vs65ubY3X9983Z26960d91",
                id_internal             =>  34,
                matches_picpay_customer =>  [ "cpf" ],
                name                    =>  "Junior Moraes",
                phone_number            =>  undef,
                user_since              =>  "1969-12-31T21:00:00-03:00"
            }
        }
    }

    my $customer_key = delete $opts{customer_key};

    my $res = $self->furl->post(
        $self->endpoint . "/customer",
        [
            'Content-Type' => "application/json",
            api_key      => $self->_api_key,
            client_id    => $self->_client_id,
            customer_key => $customer_key,
        ],
        encode_json(\%opts),
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub transfer {
    my ($self, %opts) = @_;

    if (is_test()) {
        return {
            transfer => {
                balance =>  727,
                id      =>  "tf_vs65ubYVS65USZ26960a2h",
                status  =>  "concluida",
                value   =>  50
            },
        };
    }

    my $res = $self->furl->post(
        $self->endpoint . "/transfer",
        [
            'Content-Type' => "application/json",
            api_key        => $self->_api_key,
            client_id      => $self->_client_id,
        ],
        encode_json(\%opts),
    );
    die $res->decoded_content unless $res->is_success;

    return decode_json $res->decoded_content;
}

sub _build_furl { Furl->new }

1;


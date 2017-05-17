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

1;


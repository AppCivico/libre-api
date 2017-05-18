package WebService::HttpCallback;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;

BEGIN { $ENV{LIBRE_HTTP_CB_URL} or die "missing env 'LIBRE_HTTP_CB_URL'." }

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new }

sub add {
    my ( $self, %opts ) = @_;

    if (is_test()) {
        $Libre::Test::Further::http_callback = \%opts;

        return { id => rand(10000) };
    }
    else {
        my $res;
        eval {
            retry {
                $res = $self->furl->post( $ENV{LIBRE_HTTP_CB_URL} . '/schedule', [], [%opts] );
                die $res->decoded_content unless $res->is_success;
            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        return { error => $@ } if $@;
        return { error => 'Cannot call http callback' } unless $res;

        return decode_json( $res->decoded_content );
    }
}

1;


package Libre::Model::Flotum;
use base 'Catalyst::Model';
use Moose;
use Net::Flotum;

use Libre::Utils;

has instance => (
    is         => "rw",
    isa        => "Net::Flotum",
    lazy_build => 1,
);

BEGIN { $ENV{FLOTUM_MERCHANT_API_KEY} or die "missing 'FLOTUM_MERCHANT_API_KEY'" }

sub _build_instance {
    my $self = shift;

    Net::Flotum->new(merchant_api_key => $ENV{FLOTUM_MERCHANT_API_KEY});
}

sub initialize_after_setup {
    my ($self, $app) = @_;

    $app->log->debug('Initializing Omicron::Model::Flotum...');
}

1;

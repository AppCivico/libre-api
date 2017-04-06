package Libre::Model::Flotum;
use base 'Catalyst::Model';
use Moose;
use Net::Flotum;

use Libre::Utils;

has instance => (
    is      => 'rw',
    lazy    => 1,
    builder => '_builder_flotum',
    isa     => 'Net::Flotum',
);

sub _builder_flotum {
    my $self = shift;

    if (is_test() && !$ENV{FLOTUM_MERCHANT_API_KEY}) {
        $ENV{FLOTUM_MERCHANT_API_KEY} = 'm-homol-personow-20h4+2kkd3';
    }

    Net::Flotum->new(merchant_api_key => $ENV{FLOTUM_MERCHANT_API_KEY});
}

sub initialize_after_setup {
    my ($self, $app) = @_;

    $app->log->debug('Initializing Omicron::Model::Flotum...');
}

1;

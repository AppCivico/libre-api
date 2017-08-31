package Libre;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

BEGIN {
    for (qw/ LIBRE_SLACK_WEBHOOK_URL LIBRE_SLACK_CHANNEL LIBRE_SLACK_USERNAME /) {
        defined($ENV{$_}) or die "missing env '$_'.";
    }
};

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Authentication
    Authorization::Roles
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name     => 'Libre',
    encoding => "UTF-8",

    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 0,
);

use WebService::Slack::IncomingWebHook;

has _slack_webhook => (
    is      => "ro",
    lazy    => 1,
    default => sub {
        WebService::Slack::IncomingWebHook->new(
            webhook_url => $ENV{LIBRE_SLACK_WEBHOOK_URL},
            channel     => "#" . $ENV{LIBRE_SLACK_CHANNEL},
            username    => $ENV{LIBRE_SLACK_USERNAME},
            icon_emoji  => ":robot_face:",
        );
    },
    handles => { slack_notify => [ post => "text" ] }
);

around 'slack_notify' => sub {
    my $orig = shift;
    my $self = shift;
    my $message = shift;

    my $project = lc(__PACKAGE__);
    chomp(my $hostname = `hostname`);

    eval { $self->$orig("[$project] [$hostname] " . $message, @_) };
    warn $@ if $@;
};

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

Libre - Catalyst based application

=head1 SYNOPSIS

    script/libre_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Libre::Controller::Root>, L<Catalyst>

=head1 AUTHOR

junior,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

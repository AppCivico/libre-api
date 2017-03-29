package Libre::Mailer;
use common::sense;
use Moose;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;

use Libre::Utils;

has smtp_server => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has smtp_port => (
    is       => "rw",
    isa      => "Int",
    required => 1,
);

has smtp_username => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has smtp_password => (
    is       => "rw",
    isa      => "Str",
    required => 1,
);

has smtp_timeout => (
    is      => "rw",
    isa     => "Int",
    default => 20,
);

has _transport => (
    is         => "ro",
    lazy_build => 1,
);

sub _build__transport {
    my $self = shift;

    defined $self->smtp_server   or die "missing 'smtp_server'.";
    defined $self->smtp_port     or die "missing 'smtp_port'.";
    defined $self->smtp_username or die "missing 'smtp_username'.";
    defined $self->smtp_password or die "missing 'smtp_passwd'.";

    return Email::Sender::Transport::SMTP::TLS->new(
        helo     => "Libre",
        host     => $self->smtp_server,
        timeout  => $self->smtp_timeout,
        port     => $self->smtp_port,
        username => $self->smtp_username,
        password => $self->smtp_password,
    );
}

sub send {
    my ($self, $email, $bcc) = @_;

    if (is_test()) {
        return 1;
    }

    sendmail($email, { transport => $self->_transport });
    sendmail($email, { transport => $self->_transport, to => $_ }) for @{$bcc || []};

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

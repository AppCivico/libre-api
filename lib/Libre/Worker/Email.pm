package Libre::Worker::Email;
use common::sense;
use Moose;

with "Libre::Worker";

use Libre::Mailer;

has timer => (
    is      => "rw",
    default => 5,
);

has mailer => (
    is         => "ro",
    isa        => "Libre::Mailer",
    lazy_build => 1,
);

has schema => (
    is       => "rw",
    required => 1,
);

sub listen_queue {
    my $self = shift;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;

    my @items = $self->schema->resultset('EmailQueue')->search(
        undef,
        {
            rows   => 20,
            column => [ qw(me.id me.body) ],
        },
    )->all;

    if (@items) {
        $self->logger->info(sprintf("'%d' itens serão processados.", scalar @items)) if $self->logger;

        for my $item (@items) {
            $self->exec_item($item);
        }

        $self->logger->info("Todos os items foram processados com sucesso") if $self->logger;
    }
    else {
        $self->logger->debug("Não há itens pendentes na fila.") if $self->logger;
    }
}

sub run_once {
    my ($self, $item_id) = @_;

    my $item ;
    if (defined($item_id)) {
        $item = $self->schema->resultset('EmailQueue')->find($item_id);
    }
    else {
        $item = $self->schema->resultset('EmailQueue')->search(
            undef,
            {
                rows   => 1,
                column => [ qw(me.id me.body) ],
            },
        )->next;
    }

    if ($item) {
        return $self->exec_item($item);
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    $self->logger->debug($item->body) if $self->logger;

    if ($self->mailer->send($item->body, $item->bcc)) {
        $item->delete();
        return 1;
    }

    return 0;
}

sub _build_mailer {
    my $self = shift;

    return Libre::Mailer->new(
        smtp_server   => $ENV{SMTP_SERVER},
        smtp_port     => $ENV{SMTP_PORT},
        smtp_username => $ENV{SMTP_USERNAME},
        smtp_password => $ENV{SMTP_PASSWORD},
    );
}

__PACKAGE__->meta->make_immutable;

1;


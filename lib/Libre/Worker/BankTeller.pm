package Libre::Worker::BankTeller;
use common::sense;
use Moose;

use Data::Printer;

with "Libre::Worker";

has timer => (
    is      => "rw",
    default => 5,
);

has schema => (
    is       => "rw",
    required => 1,
);

sub listen_queue {
    my $self = shift;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;

    my @items = $self->schema->resultset("MoneyTransfer")->search(
        { transferred => "false" },
        {
            rows => 20,
            for  => "update",
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

    $self->schema->resultset("MoneyTransfer")->search({}, { for => "update" })->next;

    my $money_transfer_rs = $self->schema->resultset("MoneyTransfer")->search(
        { transferred => "false" },
        { order_by => [ { '-asc' => "created_at" } ] },
    );
    my $item ;
    if (defined($item_id)) {
        $item = $money_transfer_rs->search( { 'me.id' => $item_id } )->next();
    }
    else {
        $item = $money_transfer_rs->search( {}, { rows => 1 } )->next();
    }

    if (ref $item) {
        return $self->exec_item($item);
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    my $transfer_id = $item->id;

    $self->logger->debug("Processando doação id '${\($item->id)}'...") if $self->logger;

    $item->update(
        {
            transferred    => "true",
            transferred_at => \"NOW()",
        }
    );

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;


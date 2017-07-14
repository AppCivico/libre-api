package Libre::Worker::BankTeller;
use common::sense;
use Moose;

use WebService::PicPay;
use Data::Printer;

with "Libre::Worker";

has timer => (
    is      => "rw",
    default => 3600, # 1 hour.
);

has schema => (
    is       => "rw",
    required => 1,
);

has _picpay => (
    is => "rw",
    isa => "WebService::PicPay",
    lazy_build => 1,
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
    )->all();

    if (@items) {
        $self->logger->info(sprintf("'%d' itens serão processados.", scalar @items)) if $self->logger;

        for my $item (@items) {
            eval { $self->exec_item($item) };
            if ($@) {
                $self->logger->error("Não foi possível realizar a transferência.") if $self->logger;
                $self->logger->error($@)                                           if $self->logger;

                $self->logger->debug("Provavelmente eu não tenho saldo para fazê-la.") if $self->logger;
                $self->logger->debug("Tentarei novamente mais tarde.")                 if $self->logger;
                last;
            }
        }

        $self->logger->info("Todos os items foram processados com sucesso") if $self->logger;
    }
    else {
        $self->logger->debug("Não há itens pendentes na fila.") if $self->logger;
    }
}

sub run_once {
    my ($self, $item_id) = @_;

    my $money_transfer_rs = $self->schema->resultset("MoneyTransfer")->search(
        { transferred => "false" },
        { order_by => [ { '-asc' => "created_at" } ] },
    );

    $money_transfer_rs->search( {}, { for => "update" } )->next();

    my $item ;
    if (defined($item_id)) {
        $item = $money_transfer_rs->search( { 'me.id' => $item_id } )->next();
    }
    else {
        $item = $money_transfer_rs->search( {}, { rows => 1 } )->next();
    }

    if (ref $item) {
        my $ret;
        eval { $ret = $self->exec_item($item) };
        ERROR $@ if $@;

        return $ret;
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    my $transfer_id = $item->id;

    $self->logger->debug("Processando transferência id '${\($item->id)}'...") if $self->logger;

    my $transfer = $self->_picpay->transfer(
        value       => $item->amount,
        destination => $item->journalist->customer_id,
    );

    $item->update(
        {
            transferred     => "true",
            transferred_at  => \"NOW()",
            transfer_id     => $transfer->{transfer}->{id},
            transfer_status => $transfer->{transfer}->{status},
        }
    );

    $self->logger->debug("Transferência id '${\($item->id)}' realizada com sucesso.") if $self->logger;

    return 1;
}

around 'exec_item' => sub {
    my $self = shift;
    my $orig = shift;
    my @args = @_;

    return $self->schema->txn_do(sub { $self->$orig(@args) });
};

sub _build__picpay { WebService::PicPay->new() }

__PACKAGE__->meta->make_immutable;

1;


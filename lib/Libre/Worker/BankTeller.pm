package Libre::Worker::BankTeller;
use common::sense;
use Moose;
use Data::Section::Simple qw(get_data_section);

use WebService::PicPay;
use Data::Printer;
use DateTime;

use Libre::Mailer::Template;

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
    is         => "rw",
    isa        => "WebService::PicPay",
    lazy_build => 1,
);

sub listen_queue {
    my $self = shift;

    $self->logger->debug("Buscando itens na fila...") if $self->logger;

    my @items = $self->schema->resultset("MoneyTransfer")->search(
        { 'me.transferred' => "false" },
        {
            prefetch => [ qw/ journalist / ],
            rows     => 20,
            for      => "update",
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
        $self->logger->error($@) if $self->logger && $@;

        return $ret;
    }
    return 0;
}

sub exec_item {
    my ($self, $item) = @_;

    my $transfer_id = $item->id;

    $self->logger->info("Processando transferência id '${\($item->id)}'...") if $self->logger;

    $self->logger->info("Verificando se o journalist id '${\($item->journalist->id)}' realizou authlink...") if $self->logger;
    if ($item->journalist->is_authlinked()) {
        $self->logger->info("Ok, o jornalista id '${\($item->journalist->id)}' realizou authlink!") if $self->logger;
    }
    else {
        $self->logger->info("O jornalista id '${\($item->journalist->id)}' NÃO realizou o authlink.") if $self->logger;
        $self->logger->debug("Esta transferência não será realizada por enquanto.") if $self->logger;
        return 0;
    }

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

    my $email_queue_rs = $self->schema->resultset("EmailQueue");
    my $journalist     = $self->schema->resultset("Journalist")->search(
        { 'me.user_id'   => $item->journalist_id },
        {
            join      => 'user',
            '+select' => [ 'user.email', 'user.name', 'user.surname'],
            '+as'     => [ 'email', 'name', 'surname' ]
        }
    )->next;

    my $email = Libre::Mailer::Template->new(
        to       => $journalist->get_column('email'),
        from     => 'no-reply@midialibre.org.br',
        subject  => "Libre - Recibo de seu pagamento",
        template => get_data_section('journalist-receipt.tt'),
        vars     => {
            name    => $journalist->get_column('name'),
            surname => $journalist->get_column('surname'),
            cpf     => $journalist->get_column('cpf'),
            cnpj    => $journalist->get_column('cpf'),
            amount  => 100,
            day     => DateTime->today->day,
            month   => DateTime->today->month,
            year    => DateTime->today->year,
        },
    )->build_email();

    my $queued = $email_queue_rs->create({ body => $email->as_string });

    return 1;
}

around 'exec_item' => sub {
    my $orig = shift;
    my $self = shift;
    my @args = @_;

    return $self->schema->txn_do(sub { $self->$orig(@args) });
};

sub _build__picpay { WebService::PicPay->new() }

__PACKAGE__->meta->make_immutable;

1;

__DATA__

@@ journalist-receipt.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
<td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
<p style="text-align: center;"><a href="https://midialibre.org.br/"><img src="https://gallery.mailchimp.com/af2df78bcac96c77cfa3aae07/images/c75c64c5-c400-4c18-9564-16b4a7116b03.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; align: center"></a></p>
<p><b>Olá, [% name %]. </b></p>
<br></span>
</p>
<p> <strong>Transferimos dinheiro para sua conta do PicPay com sucesso.</strong><br><br>Abaixo está o seu recibo
</p>
</td>
</tr>
<tr>
<td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
<p>
O Libre, inscrito no CNPJ sob o nº 19.131.243/0001-97, depositou para [% name %] [% surname %], inscrito no CPF sob o nº [% cpf %], a importância de R$ [% amount %] em sua conta do PicPay, concernente à venda de um plano de financiamento jornalístico.
<br><br>
São Paulo, [% day %] do [% month %] de [% year %].
<br><br>
Libre
</p>
</td>
</tr>
<tr>
<td height="30"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
<strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
<p>Dúvidas? Acesse <a href="https://www.midialibre.org.br/ajuda" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
Equipe Libre
</strong>
<a href="mailto:contato@midialibre.com.br" target="_blank" style="color:#4ab957"></a>
</td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
<tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Libre</strong></span>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div>
</div></div>
</body>
</html>

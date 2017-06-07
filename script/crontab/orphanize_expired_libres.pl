#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../../lib";

use Log::Log4perl qw(:easy);
use Libre::Utils;
use Libre::SchemaConnected;

# Log.
Log::Log4perl->easy_init({
    file   => "STDOUT",
    layout => '[%d] [%p] %m%n',
    level  => $DEBUG,
    utf8   => 1,
}, {
    file   => ">>$RealBin/../../log/$Script.log",
    layout => '[%d] %m%n',
    level  => $DEBUG,
    utf8   => 1,
});

INFO "Iniciando $Script...";

my $schema = get_schema;

INFO "Orfanizando libres...";

my $orphanized_libres = $schema->resultset("Libre")->invalid_libres();

INFO "$orphanized_libres libre(s) orfanizado(s)...";

INFO "Fim da execução.";

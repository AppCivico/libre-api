#!/usr/bin/env perl
use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../../lib";

use Log::Log4perl qw(:easy);
use Libre::Utils;
use Libre::SchemaConnected;

# Log.
# Log::Log4perl->easy_init({
#     file   => "STDOUT",
#     layout => '[%d] [%p] %m%n',
#     level  => $DEBUG,
#     utf8   => 1,
# }, {
#     file   => ">>$RealBin/../../log/$Script.log",
#     layout => '[%d] %m%n',
#     level  => $DEBUG,
#     utf8   => 1,
# });

INFO "Iniciando $Script...";

my $schema = get_schema;
my $now = DateTime->now(time_zone => "America/Sao_Paulo");

# TODO selecionar todos os libres sem user_plan e com a data > que a data max de expiração
# E invalidar o like

my $libre_rs = $schema->resultset("Libre")->search(
    { 
        user_plan_id             => undef,
        "user_plan.valid_until"  => \"IS NOT NULL",
    },
    { join => "user_plan" })
->update(
    { 
        invalid      => 1,
        invalided_at => \"NOW()", 
    },
    { for => "update" }
);

use DDP; p $libre_rs;

#my $invalided_libres = $libre_rs
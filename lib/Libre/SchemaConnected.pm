package Libre::SchemaConnected;
use common::sense;
use FindBin qw($RealBin);
use Config::General;

BEGIN {
    for (qw(POSTGRESQL_HOST POSTGRESQL_PORT POSTGRESQL_DBNAME POSTGRESQL_USER POSTGRESQL_PASSWORD)) {
        defined($ENV{$_}) or die "missing env '$_'\n";
    }
};

require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(get_schema get_connect_info);

use Libre::Schema;
use Libre::Utils;

sub get_connect_info {
    my $host     = $ENV{POSTGRESQL_HOST};
    my $port     = $ENV{POSTGRESQL_PORT} || 5432;
    my $user     = $ENV{POSTGRESQL_USER};
    my $password = $ENV{POSTGRESQL_PASSWORD};
    my $dbname   = $ENV{POSTGRESQL_DBNAME};

    return {
        dsn            => "dbi:Pg:dbname=$dbname;host=$host;port=$port",
        user           => $user,
        password       => $password,
        AutoCommit     => 1,
        quote_char     => "\"",
        name_sep       => ".",
        auto_savepoint => 1,
        pg_enable_utf8 => 1,
    };
}

sub get_schema {
    return Libre::Schema->connect(get_connect_info());
}

1;

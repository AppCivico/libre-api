package Libre::Test::Further;
use common::sense;
use FindBin qw($RealBin);
use Carp;

use Test::More;
use Catalyst::Test q(Libre);
use CatalystX::Eta::Test::REST;

use Data::Printer;
use JSON::MaybeXS;
use Data::Fake qw(Core Company Dates Internet Names Text);
use Business::BR::CPF qw(random_cpf);
use Business::BR::CNPJ qw(random_cnpj format_cnpj);
use Business::BR::RG qw(random_rg);

# ugly hack
sub import {
    strict->import;
    warnings->import;

    no strict 'refs';

    my $caller = caller;

    while (my ($name, $symbol) = each %{__PACKAGE__ . '::'}) {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{$symbol}{CODE}; # export subs only

        my $imported = $caller . '::' . $name;
        *{$imported} = \*{$symbol};
    }
}

my $obj = CatalystX::Eta::Test::REST->new(
    do_request => sub {
        my $req = shift;

        eval 'do{my $x = $req->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        my ($res, $c) = ctx_request($req);
        eval 'do{my $x = $res->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        return $res;
    },
    decode_response => sub {
        my $res = shift;
        return decode_json($res->content);
    }
);

for (qw/rest_get rest_put rest_head rest_delete rest_post rest_reload rest_reload_list/) {
    eval('sub ' . $_ . ' { return $obj->' . $_ . '(@_) }');
}

sub stash_test ($&) {
    $obj->stash_ctx(@_);
}

sub stash ($) {
    $obj->stash->{$_[0]};
}

sub test_instance {$obj}

sub db_transaction (&) {
    my ($subref, $modelname) = @_;

    my $schema = Libre->model($modelname || 'DB');

    eval {
        $schema->txn_do(
            sub {
                $subref->($schema);
                die 'rollback';
            }
        );
    };
    die $@ unless $@ =~ /rollback/;
}

my $auth_user = {};

sub api_auth_as {
    my (%conf) = @_;

    if (!exists($conf{user_id})) {
        croak "api_auth_as: missing 'user_id'.";
    }

    my $user_id = $conf{user_id};

    my $schema = Libre->model(defined($conf{model}) ? $conf{model} : 'DB');

    if ($auth_user->{id} != $user_id) {
        my $user = $schema->resultset("User")->find($user_id);
        croak 'api_auth_as: user not found' unless $user;

        my $session = $user->new_session(ip => "127.0.0.1");

        $auth_user = {
            id      => $user_id,
            api_key => $session->{api_key},
        };
    }

    $obj->fixed_headers([ 'x-api-key' => $auth_user->{api_key} ]);
}

sub create_journalist {
    my (%opts) = @_;

    my $name        = fake_name()->();

    my %params = (
        email                   => fake_email()->(),
        password                => "foobarpass",
        name                    => fake_name()->(),
        cpf                     => random_cpf(),
        rg                      => random_rg(),
        cellphone_number        => '11 94562-1234',
        adress_state            => 'São Paulo',
        adress_city             => 'São Paulo',
        adress_zipcode          => '02351-000',
        adress_street           => "Rua Flores do Piauí",
        adress_residence_number => 1 + int(rand(2000)),
        %opts
    ); 

    return $obj->rest_post(
        '/v1/register/journalist',
        name    => 'add journalist',
        stash   => 'journalist',
        [ %params ],
    );
}

1;


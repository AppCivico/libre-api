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
use Libre::Utils;

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

    my %params = (
        email                    => fake_email()->(),
        password                 => "foobarpass",
        name                     => fake_name()->(),
        surname                  => fake_surname->(),
        cpf                      => random_cpf(),
        cellphone_number         => fake_digits("+551198#######")->(),
        address_state            => 'São Paulo',
        address_city             => 'São Paulo',
        address_zipcode          => '02351-000',
        address_street           => "Rua Flores do Piauí",
        address_residence_number => fake_int(1, 2000)->(),
        vehicle                  => 0,
        %opts
    );

    return $obj->rest_post(
        '/api/register/journalist',
        name    => 'add journalist',
        automatic_load_item => 0,
        stash   => 'journalist',
        [ %params ],
    );
}

sub create_donor {
    my (%args) = @_;

    return $obj->rest_post(
        "/api/register/donor",
        name   => "create donor",
        automatic_load_item => 0,
        stash  => "donor",
        params => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
            %args,
        },
    );
}

sub fake_referer {
    return sub {
        return "http://"
            . fake_domain()->()
            . join("/", split(" ", fake_words(fake_int(2, 5)->())->()));
    };
}

1;


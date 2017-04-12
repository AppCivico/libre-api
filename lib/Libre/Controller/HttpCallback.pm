package Libre::Controller::HttpCallback;
use common::sense;
use Moose;
use namespace::autoclean;

use JSON::MaybeXS;

BEGIN { extends "CatalystX::Eta::Controller::REST" }

sub root : Chained('/') : PathPart('') CaptureArgs(0) { }

sub base : Chained('root') : PathPart('callback-for-token') : CaptureArgs(1) {
    my ($self, $c, $token) = @_;

    $c->stash->{token} = $token;
}

sub http_callback : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub http_callback_POST {
    my ( $self, $c ) = @_;

    my $token = $c->stash->{token};

    my $schema = $c->model("DB")->schema;
    my $rs     = $schema->resultset("HttpCallbackToken")->search( { token => $token, executed_at => undef } );
    my $config = $rs->next;
    unless ($config) {
        select undef, undef, undef, 0.25;   ## no critic
        $config = $rs->first;
    }

    unless ($config) {
        my $hostname = `hostname`;
        chomp($hostname);

        # se não tem tracinho, ja retorna 200
        if ( $token !~ /-/ ) {
            eval {
                $c->log->error(
                    join( ' ',
                        "[libre] HttpCallbackToken expirado por nao contem - no token e nao existir no banco",
                        $hostname,
                        $c->req->uri->as_string,
                        ( $c->req->data   ? Dumper( $c->req->data )   : '' ) . " - ",
                        ( $c->req->params ? Dumper( $c->req->params ) : '' ) ),
                );
            };
            warn $@ if $@;

            $self->status_ok( $c, entity => { error => 1 } ), $c->detach;
        }

        my ($epoch) = $token =~ /^([0-9]+)-/;
        if ( time - $epoch > 7200 ) {
            eval {
                $c->log->error(
                    join( ' ',
                        "[libre] HttpCallbackToken expirado por ter mais de 7200 seconds",
                        $hostname,
                        $c->req->uri->as_string,
                        ( $c->req->data   ? Dumper( $c->req->data )   : '' ) . " - ",
                        ( $c->req->params ? Dumper( $c->req->params ) : '' ) ),
                );
            };
            warn $@ if $@;

            $self->status_ok( $c, entity => { error => 2 } ), $c->detach;
        }
        $self->status_not_found( $c, message => 'Token not found' ), $c->detach;
    }

    eval {

        my $extra_args = $config->extra_args ? decode_json $config->extra_args : {};
        my $action_detach = {

            'credit-card-added' => '_update_credit_card',

        };

        if ( exists $action_detach->{ $config->action } ) {
            my $name = $action_detach->{ $config->action };

            $schema->txn_do(
                sub {

                    my ($locktoken) =
                      $schema->resultset('HttpCallbackToken')
                      ->search( { 'me.token' => $token }, { for => 'update', columns => [ 'token', 'executed_at' ] } )
                      ->next;

                    $self->$name( $c, $extra_args ) unless $locktoken->executed_at;

                    $config->update( { executed_at => \'now()' } );
                }
            );

        }
        else {
            die "Action '" . $config->action . "' not implemented...";
        }

    };
    if ($@) {
        $c->log->error("http_callback error $@");
        $c->response->status(500);
        $c->res->body('Internal Error');
        $c->detach;
    }

    $self->status_ok( $c, entity => { ok => 1 } );

}

sub _update_credit_card {
    my ( $self, $c, $extra_args ) = @_;

    my $user = eval { $c->model('DB::User')->search( { 'me.id' => $extra_args->{user_id} }, )->next; };
    return unless $user;

    if ( $user->donor->flotum_preferred_credit_card && $user->donor->flotum_id ) {
        my $older = decode_json( $user->donor->flotum_preferred_credit_card );

        if ( $older->{id} ) {
            $c->stash->{flotum} = $c->model("Flotum")->instance;

            my $cc = Net::Flotum::Object::CreditCard->new(
                flotum               => $c->stash->{flotum},
                id                   => $older->{id},
                merchant_customer_id => $user->donor->flotum_id,
            );
            eval { $cc->remove };

            if ($@) {
                die "Cannot remove credit-card.";
            }
        }

    }

    $user->donor->update({
        flotum_preferred_credit_card => encode_json({
            map { $_ => $c->req->data->{$_} }
              qw/id mask validity conjecture_brand created_at/
          })
    });

}


__PACKAGE__->meta->make_immutable;
1;

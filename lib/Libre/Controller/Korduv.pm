package Libre::Controller::Korduv;
use common::sense;
use Moose;
use namespace::autoclean;

use JSON::XS;
use Data::Dumper qw/Dumper/;

BEGIN { extends "Catalyst::Controller" }

sub root : Chained('/') : PathPart('korduv') : CaptureArgs(0) { }

sub success_renewal : Chained('root') : PathPart('success-renewal') : Args(1) {
    my ($self, $c, $callback_id) = @_;

    my $user_plan = $c->model('DB::UserPlan')->search( { callback_id => $callback_id } )->next();

    if ($user_plan) {
        eval { $user_plan->on_korduv_callback_success($c->req->data) };

        if ($@) {
            $c->error("[korduv::success_renewal] fail " . Dumper($@) . "\n" . Dumper($c->req->data));
            $c->res->code(500);
        }
        else {
            $c->res->code(200);
        }
    }
    $c->res->body("");
}

sub fail_forever : Chained('root') : PathPart('fail-forever') : Args(1) {
    my ($self, $c, $callback_id) = @_;

    my $user_plan = $c->model('DB::UserPlan')->search( { callback_id => $callback_id } )->next();

    if ($user_plan) {
        eval { $user_plan->on_korduv_fail_forever($c->req->data) };

        if ($@) {
            $c->error("[korduv::fail_forever]" . Dumper($@) . "\n" . Dumper($c->req->data));
            $c->res->code(500);
            use DDP; p $c;
        }
        else {
            $c->res->code(200);
        }
    }
    $c->res->body("");
}

1;


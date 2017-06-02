package Libre::Controller::API::ForgotPassword;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/login/base') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::UserForgotPassword');
}

sub base : Chained('root') : PathPart('forgot_password') : CaptureArgs(0) { }

sub forgot_password : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub forgot_password_POST {
    my ($self, $c) = @_;

    $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
   );

    return $self->status_ok($c, entity => {message => "ok"});
}

__PACKAGE__->meta->make_immutable;

1;
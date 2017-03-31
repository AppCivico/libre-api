package Libre::Controller::API::Login;
use Moose;
use namespace::autoclean;

use Libre::Types qw(EmailAddress);

BEGIN { extends "CatalystX::Eta::Controller::REST" }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('login') : CaptureArgs(0) { }

sub login : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub login_POST {
    my ($self, $c) = @_;

    $c->req->params->{email} = lc $c->req->params->{email};

    $self->validate_request_params(
        $c,
        email => {
            type     => EmailAddress,
            required => 1,
        },
        password => {
            type     => "Str",
            required => 1,
        },
    );

    my $authenticate = $c->authenticate({ map { $_ => $c->req->params->{$_} } qw(email password) });

    if ($authenticate) {
        my $ipAddr = $c->req->header("CF-Connecting-IP") || $c->req->header("X-Forwarded-For") || $c->req->address;

        my $session = $c->user->obj->new_session(
            %{$c->req->params},
            ip => $ipAddr,
        );

        return $self->status_ok($c, entity => $session);
    }

    return $self->status_bad_request($c, message => 'Bad email or password.');
}

__PACKAGE__->meta->make_immutable;

1;

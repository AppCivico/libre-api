package Libre::Controller::API::Register::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends "CatalystX::Eta::Controller::REST" }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result  => "DB::Donor",
    no_user => 1,
);

sub root : Chained('/api/register/base') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('donor') : CaptureArgs(0) { }

sub create : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub create_POST {
    my ($self, $c) = @_;

    my $user = $c->stash->{collection}->execute(
        $c,
        for => "create",
        with => $c->req->params,
    );

    return $self->status_created(
        $c,
        location => $c->uri_for($c->controller("API::User")->action_for('result'), [ $user->id ]),
        entity   => { id => $user->id },
    );
}

__PACKAGE__->meta->make_immutable;

1;
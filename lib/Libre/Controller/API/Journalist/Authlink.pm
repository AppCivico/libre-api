package Libre::Controller::API::Journalist::Authlink;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('authlink') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => $c->stash->{journalist}->get_authlink(),
    );
}

__PACKAGE__->meta->make_immutable;

1;

package Libre::Controller::API::Journalist;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    # AutoBase.
    result      => "DB::Journalist",
    result_cond => { 'user.verified' => "true" },
    result_attr => { join => "user" },
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('journalist') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    my $user = $c->stash->{collection}->find($user_id);
    $c->detach("/error_404") unless ref $user;

    $c->stash->{journalist} = $user;
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

__PACKAGE__->meta->make_immutable;

1;

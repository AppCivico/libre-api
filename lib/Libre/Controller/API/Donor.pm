package Libre::Controller::API::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result      => "DB::User",
    result_cond => { verified => "true" },
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('donor') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    my $user = $c->stash->{collection}->find($user_id);
    if (!$user || !$user->is_donor()) {
        $c->detach("/error_404");
    }

    $c->stash->{donor} = $user;
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

__PACKAGE__->meta->make_immutable;

1;

package Libre::Controller::API::User::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result  => "DB::Donation",
    
);

sub root : Chained('/api/user/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('donation') : CaptureArgs(0) { }

sub register : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub register_POST {
    my ($self, $c) = @_;

    my $donation = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    return $self->status_created(
        $c,
        entity   => { id => $donation->id },
    );
}

__PACKAGE__->meta->make_immutable;

1;

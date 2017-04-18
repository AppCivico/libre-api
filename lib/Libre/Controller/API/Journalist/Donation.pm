package Libre::Controller::API::Journalist::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result  => "DB::Donation",
    no_user => 1,
);

sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('donation') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $donation = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            donor_user_id      => $c->user->id,
            journalist_user_id => $c->stash->{journalist}->id,
        },
    );

    return $self->status_ok(
        $c,
        entity => { id => $donation->id },
    );
}

__PACKAGE__->meta->make_immutable;

1;

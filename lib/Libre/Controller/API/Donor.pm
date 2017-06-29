package Libre::Controller::API::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result      => "DB::Donor",
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('donor') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    $c->stash->{collection} = $c->stash->{collection}->search( { user_id => $user_id } );

    my $user = $c->stash->{collection}->find($user_id);
    if (!$user) {
         $c->detach("/error_404");
    }

    $c->stash->{donor} = $user;
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET {
    my ($self, $c) = @_;

    my $plan        = $c->stash->{donor}->has_plan;
    my $credit_card = $c->stash->{donor}->has_credit_card;

    return $self->status_ok(
        $c,
        entity => {
            donor_has_plan        => $plan,
            donor_has_credit_card => $credit_card,
        },
    );

}

__PACKAGE__->meta->make_immutable;

1;

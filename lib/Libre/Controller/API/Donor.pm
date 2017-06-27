package Libre::Controller::API::Donor;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoResultPUT";

__PACKAGE__->config(
    # AutoBase.
    result => "DB::Donor",

    # AutoResultPUT.
    object_key     => "donor",
    result_put_for => "update",
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('donor') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    my $user = $c->stash->{collection}->find($user_id);
    $c->detach("/error_404") unless ref $user;

    $c->stash->{is_me} = int($c->user->id == $user->id);
    $c->stash->{donor} = $user;

    $c->detach("/api/forbidden") unless $c->stash->{is_me};
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET {
    my ($self, $c) = @_;

    my $has_plan    = $c->stash->{donor}->has_plan;
    my $credit_card = $c->stash->{donor}->has_credit_card;

    return $self->status_ok(
        $c,
        entity => {
            ( map { $_ => $c->stash->{donor}->$_ } qw/phone flotum_id flotum_preferred_credit_card/ ),

            ( map { $_ => $c->stash->{donor}->user->$_ } qw/id email created_at cpf name surname/ ),

            donor_has_plan        => $has_plan,
            donor_has_credit_card => $credit_card,
        },
    );
}

sub result_PUT { }

__PACKAGE__->meta->make_immutable;

1;

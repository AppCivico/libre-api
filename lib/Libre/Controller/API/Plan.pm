package Libre::Controller::API::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends "CatalystX::Eta::Controller::REST" }

sub root :Chained('/api/root') :PathPart('donor') :CaptureArgs(0) { 
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}
 
sub base :Chained('root') :PathPart('plan') :CaptureArgs(0) { }

sub register :Chained('base') :PathPart('') :Args(0) ActionClass('REST') {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::UserPlan');
}

sub register_POST { 
    my ($self, $c) = @_;

    my $user_plan = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    return $self->status_created(
        $c,
        location => $c->uri_for($c->controller("API::User::Plan")->action_for('result'), [ $user_plan->id ]),
        entity   => { id => $user_plan->id },
    );
}

__PACKAGE__->meta->make_immutable;

1;

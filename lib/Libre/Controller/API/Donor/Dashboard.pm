package Libre::Controller::API::Donor::Dashboard;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoListGET";

__PACKAGE__->config(
    # AutoListGET
    list_key       => "user_plan",
    build_list_row => sub {
        return { $_[0]->get_columns() }
    },

    # AutoResultGET.
    object_key => "user_plan",
    build_row => sub {
        return { $_[0]->get_columns() };
    },
);

sub root : Chained('/api/donor/object') : PathPart('')  : CaptureArgs(0) { 
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('dashboard') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->stash->{donor}->user->user_plans;
}

sub list : Chained('base') : PathPart('') : Args(1) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c, $id) = @_;

    use DDP; p $id;

    if (defined($id) && (my $user_plan = $c->stash->{collection}->find($id))) {
        $c->stash->{user_plan} = $user_plan;
    }
    else {
        $c->detach("/error_404");
    }

    
    return $self->status_ok(
        $c,
        entity => {

        },
    );
}

__PACKAGE__->meta->make_immutable;

1;
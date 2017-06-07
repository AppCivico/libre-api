package Libre::Controller::API::Donor::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoListGET";
with "CatalystX::Eta::Controller::AutoResultGET";

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

sub root : Chained('/api/donor/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('plan') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->stash->{donor}->user->user_plans;
}

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    if (defined($id) && (my $user_plan = $c->stash->{collection}->find($id))) {
        $c->stash->{user_plan} = $user_plan;
    }
    else {
        $c->detach("/error_404");
    }
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $user_plan = $c->stash->{collection}->execute(
        $c,
        for  => "upsert",
        with => $c->req->params,
    );

    $self->status_created(
        $c,
        entity   => { id => $user_plan->id },
        location => $c->uri_for( $self->action_for("result"), [ @{ $c->req->captures }, $user_plan->id ] ),
    );
}

sub list_GET { }

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { }

=encoding utf8

=head1 AUTHOR

eokoe-lucas,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Libre::Controller::API::Donor::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoListGET";

__PACKAGE__->config(
    # AutoBase
    result => "DB::UserPlan",

    # AutoListGET
    list_key       => "user_plan",
    build_list_row => sub {
        return { $_[0]->get_columns() }
    },
);

sub root : Chained('/api/donor/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('plan') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::UserPlan');
}

sub list_POST {
    my ($self, $c) = @_;

    my $user_plan = $c->stash->{donor}->user_plans->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    $self->status_ok(
        $c,
        entity => { id => $user_plan->id },
    );

    my $test = $c->stash->{donor}->has_plan();
}

sub list_GET { }

=encoding utf8

=head1 AUTHOR

eokoe-lucas,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

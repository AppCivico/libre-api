package Libre::Controller::API::User::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/user/object') : PathPart('') : CaptureArgs(0) { 
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}
 
sub base : Chained('root') : PathPart('plan') : CaptureArgs(0) { }


sub register : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') {
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

    $self->status_ok(
        $c,
        #location => $c->uri_for($c->controller("API::User::Plan")->action_for('result'), [ $user_plan->id ]),
        entity   => { id => $user_plan->id },
    );
}

sub list : Chained('base') : PathPart('list') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => {
            user_plan => $c->stash->{collection}->all_with_placeholder_as_arrayref(),
        },
    );
}


=encoding utf8

=head1 AUTHOR

eokoe-lucas,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Libre::Controller::API::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root :Chained('/api/root') :PathPart('user') :CaptureArgs(0) { 
    my $c = @_;

    $c->assert_user_roles("donor");
        eval { $c->assert_user_roles(qw/donor/) };
        if ($@) {
            $c->forward("/api/forbidden");
        }
}
 
sub base :Chained('root') :PathPart('plan') :CaptureArgs(0) { }

sub list :Chained('base') :PathPart('') :Args(0) ActionClass('REST') {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::UserPlan');
}

sub list_POST { 
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



=encoding utf8

=head1 AUTHOR

eokoe-lucas,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

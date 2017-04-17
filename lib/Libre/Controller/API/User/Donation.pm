package Libre::Controller::API::User::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoListGET";

__PACKAGE__->config(
    result  => "DB::Donation",
    no_user => 1,

    # AutoListGET
    list_key       => "user_plan",
    build_list_row => sub {
        return { $_[0]->get_columns() }
    },
);

sub root : Chained('/api/user/object') : PathPart('') : CaptureArgs(0) {
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

    my $donation = $c->stash->{donor}->donations->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    return $self->status_ok(
        $c,
        entity   => { id => $donation->id },
    );
}

sub list_GET { }

__PACKAGE__->meta->make_immutable;

1;

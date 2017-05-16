package Libre::Controller::API::Journalist::Support;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoObject";
with "CatalystX::Eta::Controller::AutoResultGET";

__PACKAGE__->config(
    result  => "DB::Libre",
    no_user => 1,

    # AutoBase
    object_key         => "support",
    object_verify_type => "int",

    # AutoResultGET
    build_row => sub {
        return { $_[0]->get_columns() };
    },
);

sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('support') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $support = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => {
            donor_id      => $c->user->id,
            journalist_id => $c->stash->{journalist}->id,
        },
    );

    return $self->status_created(
        $c,
        entity   => { id => $support->id },
        location => $c->uri_for($self->action_for('result'), [ $c->stash->{journalist}->id, $support->id ]),
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { }

__PACKAGE__->meta->make_immutable;

1;

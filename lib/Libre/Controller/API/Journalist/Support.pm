package Libre::Controller::API::Journalist::Support;
use common::sense;
use Moose;
use namespace::autoclean;
use Libre::Utils qw(is_test);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::Search';
with "CatalystX::Eta::Controller::AutoObject";
with "CatalystX::Eta::Controller::AutoResultGET";

__PACKAGE__->config(
    # AutoObject.
    object_key         => "support",
    object_verify_type => "int",

    # AutoResultGET
    build_row => sub {
        return { $_[0]->get_columns() };
    },

    # Search.
    search_ok => {
        page_title   => "Str",
        page_referer => "Str",
    },
);


sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('support') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model("DB::Libre")->search(
        {
            donor_id      => $c->user->id,
            journalist_id => $c->stash->{journalist}->id,
        },
    );
}

sub object : Chained('base') : PathPart('') : CaptureArgs(1) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET { }

sub list_POST {
    my ($self, $c) = @_;

    my $libre = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

    if (!is_test()) {
        $c->slack_notify(
            "O doador id '${\($c->user->id)}' apoiou o jornalista id '${\($c->stash->{journalist}->id)}'."
        );
    }

    return $self->status_created(
        $c,
        location => $c->uri_for( $self->action_for('result'), [ @{ $c->req->captures }, $libre->id ] )->as_string,
        entity   => { id => $libre->id }
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { }

__PACKAGE__->meta->make_immutable;

1;

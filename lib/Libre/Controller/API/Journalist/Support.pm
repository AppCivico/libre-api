package Libre::Controller::API::Journalist::Support;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::Search';
with "CatalystX::Eta::Controller::AutoObject";
with "CatalystX::Eta::Controller::AutoResultGET";

# TODO caso o valor do libre seja menor que X deve ser iniciado um fluxo a definir.

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

sub list_GET {
    my ($self, $c) = @_;

    my $donor_plan = $c->user->obj->donor->get_current_plan();

    return $self->status_ok(
        $c,
        entity => [
            $c->stash->{collection}->is_valid->search(
                { user_plan_id  => $donor_plan ? [ $donor_plan->id, undef ] : undef },
                {
                    columns => [ qw/id donor_id created_at page_referer page_title user_plan_id donor_id journalist_id/ ],
                    order_by => { '-desc' => "created_at" },
                    result_class => "DBIx::Class::ResultClass::HashRefInflator",
                }
            )
            ->all(),
        ]
    );
}

sub list_POST {
    my ($self, $c) = @_;

    my $libre = $c->stash->{collection}->execute(
        $c,
        for  => "create",
        with => $c->req->params,
    );

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

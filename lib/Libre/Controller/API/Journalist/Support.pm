package Libre::Controller::API::Journalist::Support;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::Search';
with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoObject";
with "CatalystX::Eta::Controller::AutoResultGET";
with "CatalystX::Eta::Controller::AutoListPOST";

# TODO caso o valor do libre seja menor que X deve ser iniciado um fluxo a definir.

__PACKAGE__->config(
    # AutoObject.
    result  => "DB::Libre",
    no_user => 1,

    # AutoBase
    object_key         => "support",
    object_verify_type => "int",

    # AutoResultGET
    build_row => sub {
        return { $_[0]->get_columns() };
    },

    # AutoListPOST.
    prepare_params_for_create => sub {
        my ($self, $c) = @_;

        return {
            donor_id      => $c->user->id,
            journalist_id => $c->stash->{journalist}->id,
            page_title    => $c->req->params->{page_title},
            page_referer  => $c->req->params->{page_referer},
        };
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

sub base : Chained('root') : PathPart('support') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    my $donor_plan = $c->user->obj->donor->get_current_plan();

    return $self->status_ok(
        $c,
        entity => [
            $c->stash->{collection}->is_valid->search(
                {
                    donor_id      => $c->user->id,
                    journalist_id => $c->stash->{journalist}->id,
                    user_plan_id  => $donor_plan ? [ $donor_plan->id, undef ] : undef, 
                },
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

sub list_POST { }

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { }

__PACKAGE__->meta->make_immutable;

1;

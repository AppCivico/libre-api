package Libre::Controller::API::Journalist::Dashboard;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoListGET";

__PACKAGE__->config(
    # AutoListGET
    list_key       => "journalist",
    build_list_row => sub {
        return { $_[0]->get_columns() }
    },

    # AutoResultGET.
    #object_key => "journalist",
    #build_row => sub {
    #    return { $_[0]->get_columns() };
    #},
);

sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/journalist/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('dashboard') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model("DB::Libre")->search(
        {
            journalist_id => $c->user->id,
        },
    );
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    my $journalist_id = $c->user->id;

    my $page   = $c->req->params->{page}    || 1;
    my $offset = $c->req->params->{results} || 20;

    return $self->status_ok(
        $c,
        entity => [
            $c->stash->{collection}->is_valid->search(
                { journalist_id => $journalist_id },
                {
                    columns      =>
                        [
                            'page_referer',
                            'page_title',
                            { times_supported => { count => \'1' } },
                            { last_created_at => \'max(created_at) as last_created_at' },
                        ],
                    group_by     => [ 'page_referer', 'page_title' ],
                    order_by     => \'last_created_at',
                    result_class => "DBIx::Class::ResultClass::HashRefInflator",
                    page         => $page,
                    rows         => $offset,
                },
            )
            ->all(),
        ]
    );
}

__PACKAGE__->meta->make_immutable;

1;
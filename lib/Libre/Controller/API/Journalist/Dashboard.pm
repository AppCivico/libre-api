package Libre::Controller::API::Journalist::Dashboard;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Utils;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/journalist/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('dashboard') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model("DB::Libre")->search( { journalist_id => $c->stash->{journalist}->id } );
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

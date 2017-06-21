package Libre::Controller::API::Donor::Support;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with 'CatalystX::Eta::Controller::Search';

__PACKAGE__->config(

    # Search.
    search_ok => {
        page_title   => "Str",
        page_referer => "Str",
    },
);

sub root : Chained('/api/donor/object') : PathPart('') : CaptureArgs(0) {
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
            donor_id => $c->user->id,
        },
    );
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    # TODO Isto necessita de um módulo mais organizado
    # com métodos específicos para jornalista e doador

    my $donor_plan = $c->user->obj->donor->get_current_plan();

    return $self->status_ok(
        $c,
        entity => [
            $c->stash->{collection}->is_valid->search(
                { user_plan_id  => $donor_plan ? [ $donor_plan->id, undef ] : undef },
                {
                    columns      => [ qw/id donor_id created_at page_referer page_title user_plan_id donor_id journalist_id/ ],
                    order_by     => { '-desc' => "created_at" },
                    result_class => "DBIx::Class::ResultClass::HashRefInflator",
                    page         => 1,
                    rows         => 10,
                },
            )
            ->all(),
        ]
    );
}

__PACKAGE__->meta->make_immutable;

1;
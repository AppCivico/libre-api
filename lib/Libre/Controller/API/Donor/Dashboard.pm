package Libre::Controller::API::Donor::Dashboard;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Utils;
use DateTime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoListGET";

__PACKAGE__->config(
    # AutoListGET
    list_key       => "user_plan",
    build_list_row => sub {
        return { $_[0]->get_columns() }
    },

    # AutoResultGET.
    object_key => "user_plan",
    build_row => sub {
        return { $_[0]->get_columns() };
    },
);

sub root : Chained('/api/donor/object') : PathPart('')  : CaptureArgs(0) { 
    my ($self, $c) = @_;

    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('dashboard') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->stash->{donor}->user->user_plans;
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    my $donor_id   = $c->user->id;
    my $donor_rs   = $c->stash->{collection}->schema->resultset("Donor");
    my $user_plan  = $donor_rs->find($donor_id)->get_current_plan();

    # TODO mostrar até libres órfãos, mas avisar que não serão doados se não tiverem plano
   my $libres = $c->model("DB::Libre")->search(
        {
            user_plan_id => [ undef, $user_plan->id ],
            invalid      => "false",
        }
    )->count;

    # TODO mostrar next_billing_at
    # if (is_test()) {
    #     $next_billing_at = DateTime->now(),
    # }

    return $self->status_ok(
        $c,
        entity => {
            user_plan_amount => $user_plan->amount,
            libres_donated   => $libres,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

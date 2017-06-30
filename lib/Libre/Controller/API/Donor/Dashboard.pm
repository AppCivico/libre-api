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

sub base : Chained('root') : PathPart('dashboard') : CaptureArgs(0) { }

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;

    my $donor     = $c->stash->{donor};
    my $donor_id  = $donor->id;
    my $donor_rs  = $c->stash->{collection};

    my $user_plan  = $donor->get_current_plan();

    my $libres = $c->model("DB::Libre")->search(
        {
            user_plan_id => ref $user_plan ? [ $user_plan->id, undef ] : undef,
            invalid      => "false",
            donor_id     => $donor_id,
        }
    )->count;

    # TODO mostrar next_billing_at
    # if (is_test()) {
    #     $next_billing_at = DateTime->now(),
    # }

    return $self->status_ok(
        $c,
        entity => {
            user_plan_amount => ref $user_plan ? $user_plan->amount : undef,
            libres_donated   => $libres,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

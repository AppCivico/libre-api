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

    my $donor = $c->stash->{donor};

    my $libres = $c->model("DB::Libre")->search(
        {
            'me.invalid'  => 'false',
            'me.donor_id' => $donor->get_column('user_id'),
        }
    )->count;

    my $user_plan = $donor->get_current_plan();

    my $subscription = $donor->get_korduv_subscription();

    return $self->status_ok(
        $c,
        entity => {
            user_plan_amount => ref $user_plan ? $user_plan->amount : undef,
            next_billing_at  => ref $subscription ? $subscription->{status}->{next_billing_at} : undef,
            libres_donated   => $libres,
            balance          => $donor->get_balance(),
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

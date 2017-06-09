package Libre::Controller::API::Donor::Dashboard;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Utils;
use Furl;
use DateTime;

BEGIN {
    extends 'CatalystX::Eta::Controller::REST';
    $ENV{LIBRE_KORDUV_URL} or die "missing env 'LIBRE_KORDUV_URL'.";
}

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

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new }

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
    my ($self, $c, %opts) = @_;

    my $next_billing_at;
    my $plan = $c->model("DB::UserPlan")->search(
        {
            user_id => $c->user->id,
        }
    )->next;
    
    # TODO mostrar até libres órfãos, mas avisar que não serão doados se não tiverem plano
    my $libres = $c->model("DB::Libre")->search(
        {
            user_plan_id => $plan->id,
            invalid      => 0,
            orphaned_at  => \"IS NULL",
        }
    )->count;

    # TODO mostrar next_billing_at
    # if (is_test()) {
    #     $next_billing_at = DateTime->now(),
    # }

    # Isto não deve estar certo...
    # else {
    #     my $res;
    #     eval {
    #         retry {
    #             $res = $self->furl->get( $ENV{LIBRE_KORDUV_URL} . '/subscriptions');
    #             die $res->decoded_content unless $res->is_success;
    #         }
    #         retry_of { shift() < 3 } catch { die $_; };
    #     };

    #     die "Error: $@" if $@;
    #     die "Cannot call GET on korduv" unless $res;
    #     die "Request failed: " . $res->as_string unless $res->is_success;

    #     $next_billing_at = decode_json( $res->decoded_content->status->next_billing_at );
    # }

    return $self->status_ok(
        $c,
        entity => {
            user_plan_amount => $plan->amount,
            libres_donated   => $libres,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;
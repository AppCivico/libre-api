package Libre::Controller::API::Donor::CreditCard;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

use Libre::Utils;
use Libre::Types qw(CPF);

sub root : Chained('/api/donor/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    # Somente doadores podem cadastrar cartão de crédito.
    eval { $c->assert_user_roles(qw/donor/) };
    if ($@) {
        $c->forward("/api/forbidden");
    }
}

sub base : Chained('root') : PathPart('credit-card') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{flotum}          = $c->model("Flotum")->instance;
    $c->stash->{flotum_customer} = $self->_load_customer($c);
}

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $cc_id) = @_;

    $c->stash->{cc_id} = $cc_id;
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $res;
    $c->model("DB")->txn_do(sub{
        my $token = $c->model('DB')->resultset("HttpCallbackToken")->create_for_action(
            'credit-card-added',
            { user_id => $c->stash->{donor}->id }
        );

        $res = $c->stash->{flotum_customer}->add_credit_card(callback => get_libre_api_url_for("/callback-for-token/$token"));
    });

    return $self->status_ok($c, entity => $res);
}

sub list_GET {
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => {
            credit_cards => [
                map {
                    my $r = $_;
                    +{
                        map { $_ => $r->$_ }
                          qw(
                            id
                            validity
                            conjecture_brand
                            mask
                            verified_by_any_merchant
                            created_at
                          )
                      }
                } $c->stash->{flotum_customer}->list_credit_cards
            ]
        }
    );
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_DELETE {
    my ($self, $c) = @_;

    if (ref $c->stash->{donor}->get_current_plan()) {
        $self->status_bad_request($c, message => "you have an active plan.");
        $c->detach();
    }

    my $cc = Net::Flotum::Object::CreditCard->new(
        flotum               => $c->stash->{flotum},
        id                   => $c->stash->{cc_id},
        merchant_customer_id => $c->stash->{flotum_customer}->id
    );

    eval { $cc->remove() };
    if ($@) {
        $c->error->log($@);
        $self->status_bad_request($c, error => "Cannot remove credit-card.");
        $c->detach();
    }

    $c->stash->{donor}->user->donor->update( { flotum_preferred_credit_card => undef } );

    $self->status_no_content($c);
}

sub _load_customer {
    my ($self, $c) = @_;

    my $donor = $c->stash->{donor};
    my $user  = $donor->user;

    if ($donor->flotum_id) {
        return $c->stash->{flotum}->load_customer(id => $donor->flotum_id);
    }
    else {
        my $customer = $c->stash->{flotum}->new_customer(
            name           => $user->name,
            remote_id      => $user->id,
            legal_document => $c->req->params->{cpf} || $donor->cpf || "missing",
        );

        $donor->update( { flotum_id => $customer->id } );

        return $customer;
    }
}

__PACKAGE__->meta->make_immutable;

1;

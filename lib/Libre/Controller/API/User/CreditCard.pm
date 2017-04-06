package Libre::Controller::API::User::CreditCard;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

use Libre::Utils;
use Libre::Types qw(CPF);

sub root : Chained('/api/user/object') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    # Somente doadores podem cadastrar cartão de crédito.
    $c->assert_user_roles("donor");
}

sub base : Chained('root') : PathPart('credit-card') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{flotum}          = $c->model("Flotum")->instance;
    $c->stash->{flotum_customer} = $self->_load_customer($c);
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $res;
    $c->model("DB")->txn_do(sub{
        my $token = $c->model('DB')->resultset("HttpCallbackToken")->create_for_action(
            'credit-card-added',
            { user_id => $c->stash->{user}->id }
        );

        $res = $c->stash->{flotum_customer}->add_credit_card(callback => get_libre_api_url_for("/callback-for-token/$token"));
    });

    return $self->status_ok($c, entity => $res);
}

sub _load_customer {
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    if ($user->donor->flotum_id) {
        return $c->stash->{flotum}->load_customer(id => $user->donor->flotum_id);
    }
    else {
        my $customer = $c->stash->{flotum}->new_customer(
            name           => $user->donor->name,
            remote_id      => $user->id,
            legal_document => $user->cpf || "missing",
        );

        $user->donor->update({ flotum_id => $customer->id });

        return $customer;
    }
}

__PACKAGE__->meta->make_immutable;

1;

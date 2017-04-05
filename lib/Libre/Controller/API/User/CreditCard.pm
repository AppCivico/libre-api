package Libre::Controller::API::User::CreditCard;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/api/user/object') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('credit-card') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{flotum} = $c->model("Flotum")->instance;
}

sub list : Chained('base') : PathPart('') : Args(0) : ActionClass('REST') { }

sub list_POST {
    my ($self, $c) = @_;

    my $token = $c->model('DB')->resultset('HttpCallbackToken')->create_for_action(
        'credit-card-added',
        { user_id => $c->stash->{user}->id }
    );

    use DDP; p $token;
}

__PACKAGE__->meta->make_immutable;

1;

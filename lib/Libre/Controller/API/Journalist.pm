package Libre::Controller::API::Journalist;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoResultPUT";

__PACKAGE__->config(
    # AutoBase.
    result      => "DB::Journalist",
    result_cond => { 'user.verified' => "true" },
    result_attr => { join => "user" },

    # AutoResultPUT.
    object_key     => "journalist",
    result_put_for => "update",

    # AutoResultGET
    # object_key => "journalist",
    # build_row  => sub {
    #     my ($result) = @_;

    #     return {
    #         map { $_ => $result->get_column($_) } qw/user_id address_state address_city address_zipcode address_street address_residence_number cellphone_number/
    #     };
    # },
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('journalist') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    # my $user = $c->stash->{collection}->find($user_id);
    # $c->detach("/error_404") unless ref $user;

    # $c->stash->{journalist} = $user;

    $c->stash->{collection} = $c->stash->{collection}->search( { user_id => $user_id } );

    my $user = $c->stash->{collection}->find($user_id);
    $c->detach("/error_404") unless ref $user;

    $c->stash->{is_me} = int($c->user->id == $user->id);
    $c->stash->{journalist} = $user;

    $c->detach("/api/forbidden") unless $c->stash->{is_me};
}

sub result : Chained('object') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET { 
    my ($self, $c) = @_;

    return $self->status_ok(
        $c,
        entity => {
            ( map { $_ => $c->stash->{journalist}->$_ } qw/address_state address_city address_zipcode address_street address_residence_number cellphone_number/ ),

            ( map { $_ => $c->stash->{journalist}->user->$_ } qw/id email created_at name surname/ ),
        }
    );
}

sub result_PUT { }

__PACKAGE__->meta->make_immutable;

1;

package Libre::Controller::API::Journalist::Register;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

Libre::Controller::API::Journalist::Register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root :Chained('/v1/root') :PathPart('') :CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{collection} = $c->model('DB::Journalist');
}

sub base :Chained('root') :PathPart('register') :CaptureArgs(0) { }

sub register :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub Register_POST {
    my ($self, $c) = @_;

    my $journalist = $c->stash->{collection}->execute(
        $c,
        for   => 'create',
        with  => {
            %{ $c->req->params },
            status => "pending",
        },
    );

    # Enviando e-mail de confirmação
    $journalist->send_email_registration();

    $self->status_created(
        $c,
        location => $c->uri_for($c->controller('API::Journalist')->action_for('journalist'), [$journalist->id]),
        entity   => { id => $journalist->id }
    );
}

=encoding utf8

=head1 AUTHOR

eokoe-lucas,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
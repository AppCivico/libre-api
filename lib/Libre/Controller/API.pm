package Libre::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

Libre::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/') : PathPart('v1') : CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->response->headers->header(charset => "utf-8");

    my $api_key = $c->req->param('api_key') || $c->req->header('X-API-Key');

    # Como utilizamos Cloudflare, não dá pra validar a api_token por IP pois cada hora a request vem de um IP diferente.
    if (defined($api_key)) {
        my $user_session = $c->model('DB::UserSession')->search({
            api_key      => $api_key,
            #valid_for_ip => $c->req->address,
        })->next;

        if ($user_session) {
            my $user = $c->find_user({ id => $user_session->user_id });
            $c->set_authenticated($user);
        }
    }
}

sub logged : Chained('root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    if (!$c->user) {
        $c->forward('forbidden');
    }
}

sub forbidden : Private {
    my ($self, $c) = @_;

    $self->status_forbidden($c, message => "access denied");
    $c->detach();
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

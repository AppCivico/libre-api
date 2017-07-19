package Libre::Controller::API::Register::Journalist;
use Moose;
use common::sense;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";

__PACKAGE__->config(
    result  => "DB::Journalist",
    no_user => 1,
);

sub root :Chained('/api/register/base') :PathPart('') :CaptureArgs(0) { }

sub base :Chained('root') :PathPart('journalist') :CaptureArgs(0) { }

sub register :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub register_POST {
    my ($self, $c) = @_;

    my $user = $c->stash->{collection}->execute(
        $c,
        for   => 'create',
        with  => $c->req->params,
    );

    return $self->status_created(
        $c,
        location => $c->uri_for($c->controller("API::Journalist")->action_for('result'), [ $user->id ]),
        entity   => { id => $user->id }
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

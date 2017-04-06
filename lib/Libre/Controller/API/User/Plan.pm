package Libre::Controller::API::User::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root :Chained('/api/root') :PathPart('user') :CaptureArgs(0) { }
 
sub base :Chained('root') :PathPart('plan') :CaptureArgs(0) { }

sub list :Chained('base') :PathPart('') :Args(0) ActionClass('REST') { }

sub list_GET { 
    my ($self, $c) = @_;

    my $plan_rs = $c->model("DB::Plan")->search({ id => $c->user->id });

    return $self->status_ok(
        $c,
        entity => {
            plan => $c->stash->{plan_rs}->search(
            {},
            {
                result_class => "DBIx::Class::ResultClass::HashRefInflator",
            }
            )->next
        },
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

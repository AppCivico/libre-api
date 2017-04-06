package Libre::Controller::API::Donor::Plan;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

Libre::Controller::API::Donor::Plan - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root :Chained('api/register/donor/base') :PathPart('') :CaptureArgs(0) { }
 
sub base :Chained('root') :PathPart('plan') :CaptureArgs(0) { }

sub register :Chained('base') :PathPart {
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

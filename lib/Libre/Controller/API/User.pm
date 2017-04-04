package Libre::Controller::API::User;
use common::sense;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::AutoBase";
with "CatalystX::Eta::Controller::AutoObject";

__PACKAGE__->config(
    result             => "DB::User",
    result_cond        => { verified => "true" },
    object_verify_type => "int",
    object_key         => "user",
);

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('user') : CaptureArgs(0) { }

sub object : Chained('base') : PathPart('') : CaptureArgs(1) { }

__PACKAGE__->meta->make_immutable;

1;

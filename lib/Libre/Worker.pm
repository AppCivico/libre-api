package Libre::Worker;
use Moose::Role;

requires "exec_item";
requires "listen_queue";
requires "run_once";

has timer => (
    is       => "ro",
    isa      => "Int",
    required => 1,
);

has logger => (
    is       => "rw",
    isa      => "Log::Log4perl::Logger",
    required => 0,
);

has config => (
    is      => "rw",
    isa     => "HashRef",
    default => sub { {} },
);

1;


package Libre::Schema::ResultSet::HttpCallbackToken;
use common::sense;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';

use JSON::XS;
use Crypt::PRNG qw/random_bytes_hex/;

use Libre::Utils;

sub create_for_action {
    my ( $self, $action, $extra ) = @_;

    $extra = encode_json $extra if defined $extra;

    my $code =
        time . '-'
      . random_bytes_hex(22)
      . ( is_test() ? '-forkprove-testing-you-idiot' : '' )
    ;

    $self->create(
        {
            token      => $code,
            action     => $action,
            extra_args => $extra
        }
    );
    return $code;
}

1

package Libre::Types;
use common::sense;

use MooseX::Types -declare => [
    qw(
        NotTooBigString Int CEP
        CPF CNPJ RG PositiveInt
        EmailAddress
    )
];

use Email::Valid;
use MooseX::Types::Common::String qw(NonEmptySimpleStr NonEmptyStr);
use MooseX::Types::Moose qw(Str Int ArrayRef ScalarRef Num);
use Moose::Util::TypeConstraints;
use DateTimeX::Easy qw(parse);
use MooseX::Types::Structured qw(Dict Tuple Optional);
use MooseX::Types::DateTime::MoreCoercions qw( DateTime );
use Business::BR::CEP qw(test_cep);
use Business::BR::CPF qw(test_cpf);
use Business::BR::CNPJ qw(test_cnpj);
use Business::BR::RG qw(test_rg);

use DateTime;
use DateTime::Format::Pg;

subtype PositiveInt,as Int,where { $_ >= 0 },message {"Int is not larger than 0"};

subtype CPF, as NonEmptyStr, where {
    my $cpf = $_;
    $cpf =~ s/\D+//g;
    $cpf !~ /^0+$/ && test_cpf($cpf);
};

subtype CNPJ, as NonEmptyStr, where {
    my $cnpj = $_;
    $cnpj =~ s/\D+//g;
    $cnpj !~ /^0+$/ && test_cnpj($cnpj);
};

subtype RG, as NonEmptyStr, where {
    my $rg = $_;
    $rg =~ s/\D+//g;
    test_rg($rg);
};

subtype CEP, as Str, where {
    my $cep = $_;

    $cep =~ s/\D+//g;
    $cep =~ s/^(\d+)(\d{3})$/$1-$2/;

    return test_cep($cep);
}, message {"$_[0] is not a valid CEP"};

coerce CEP, from Str, via {
    s/\D+//g;
    $_
};

subtype EmailAddress,as Str,
  where { Email::Valid->address(-address => $_) eq $_ },
  message {'Must be a valid email address'}
;

1;


package Libre::Controller::API::Contact;
use common::sense;
use Moose;
use namespace::autoclean;

use Libre::Mailer::Template;
use Libre::Types qw(EmailAddress);

use Data::Section::Simple qw(get_data_section);

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

with "CatalystX::Eta::Controller::TypesValidation";

sub root : Chained('/api/root') : PathPart('') : CaptureArgs(0) { }

sub base : Chained('root') : PathPart('contact') : CaptureArgs(0) { }

sub contact : Chained('base') : Args(0) : PathPart('') {
    my ($self, $c) = @_;

    $self->validate_request_params(
        $c,
        company => {
            required => 1,
            type     => "Str",
        },
        name => {
            required => 1,
            type     => "Str",
        },
        subject => {
            required => 1,
            type     => "Str",
        },
        email => {
            required => 1,
            type     => EmailAddress,
        },
        phone => {
            required => 1,
            type     => "Str",
        },
        message => {
            required => 1,
            type     => "Str",
        },
    );

    my $email = Libre::Mailer::Template->new(
        to       => $ENV{CONTACT_EMAIL_TO},
        from     => $ENV{DEFAULT_EMAIL_FROM},
        subject  => "Libre - Contato",
        template => get_data_section('contact.tt'),
        vars     => {
            user_agent => $c->req->user_agent || "N/A",
            map { $_ => $c->req->params->{$_} }
              qw(company name subject email phone message)
        }
    )->build_email();

    my $bcc = ['bruno.benjamin@avina.net'];
    if ($c->req->params->{subject} =~ m{^\[Dúvidas sobre o site}) {
        push @{ $bcc }, 'kogan.ariel@gmail.com';
    }

    my $queued = $c->model('DB::EmailQueue')->create(
        {
            body => $email->as_string,
            bcc  => $bcc,
        }
    );

    return $self->status_ok($c, entity => { id => $queued->id });
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__

@@ contact.tt

Empresa: [% company %]
<br>
Nome: [% name %]
<br>
Assunto: [% subject %]
<br>
Email: [% email %]
<br>
Telefone: [% phone %]
<br>
User-Agent: [% user_agent %]
<br><br>
[% message %]

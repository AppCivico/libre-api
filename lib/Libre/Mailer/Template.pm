package Libre::Mailer::Template;
use Moose;
use namespace::autoclean;

use Template;
use File::MimeInfo;
use MIME::Lite;
use Encode;

use Libre::Types qw(EmailAddress);

has to => (
    is       => "ro",
    isa      => EmailAddress,
    required => 1,
);

has subject => (
    is       => "ro",
    isa      => "Str",
    required => 1,
);

has from => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

has attachments => (
    is      => "rw",
    isa     => "ArrayRef[HashRef]",
    traits  => ["Array"],
    default => sub { [] },
    handles => { add_attachment => "push" },
);

has template => (
    is       => "ro",
    isa      => "Str",
    required => 1,
);

has vars => (
    is       => "ro",
    isa      => "HashRef",
    default  => sub { {} },
);

sub build_email {
    my ($self) = @_;

    my $tt = Template->new(EVAL_PERL => 0);

    my $content ;
    $tt->process(
        \$self->template,
        $self->vars,
        \$content,
    );

    my $email = MIME::Lite->new(
        To       => $self->to,
        Subject  => Encode::encode("MIME-Header", $self->subject),
        From     => $self->from,
        Type     => "text/html",
        Data     => $content,
        Encoding => 'base64',
    );

    for my $attachment (@{ $self->attachments }) {
        if (!ref($attachment->{fh}) || !$attachment->{fh}->isa("IO::Handle")) {
            die "invalid attachment.";
        }

        $email->attach(
            Path        => $attachment->{fh}->filename,
            Type        => mimetype($attachment->{fh}->filename),
            Filename    => $attachment->{name},
            Disposition => "attachment",
            Encoding    => "base64",
        );
    }

    return $email;
}

__PACKAGE__->meta->make_immutable;

1;


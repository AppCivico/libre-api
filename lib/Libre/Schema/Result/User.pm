use utf8;
package Libre::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_id_seq'

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 verified

  data_type: 'boolean'
  is_nullable: 0

=head2 verified_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 surname

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "email",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "verified",
  { data_type => "boolean", is_nullable => 0 },
  "verified_at",
  { data_type => "timestamp", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "surname",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("user_email_key", ["email"]);

=head1 RELATIONS

=head2 donor

Type: might_have

Related object: L<Libre::Schema::Result::Donor>

=cut

__PACKAGE__->might_have(
  "donor",
  "Libre::Schema::Result::Donor",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 journalist

Type: might_have

Related object: L<Libre::Schema::Result::Journalist>

=cut

__PACKAGE__->might_have(
  "journalist",
  "Libre::Schema::Result::Journalist",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 libre_donors

Type: has_many

Related object: L<Libre::Schema::Result::Libre>

=cut

__PACKAGE__->has_many(
  "libre_donors",
  "Libre::Schema::Result::Libre",
  { "foreign.donor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 libre_journalists

Type: has_many

Related object: L<Libre::Schema::Result::Libre>

=cut

__PACKAGE__->has_many(
  "libre_journalists",
  "Libre::Schema::Result::Libre",
  { "foreign.journalist_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 payments

Type: has_many

Related object: L<Libre::Schema::Result::Payment>

=cut

__PACKAGE__->has_many(
  "payments",
  "Libre::Schema::Result::Payment",
  { "foreign.donor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_forgot_passwords

Type: has_many

Related object: L<Libre::Schema::Result::UserForgotPassword>

=cut

__PACKAGE__->has_many(
  "user_forgot_passwords",
  "Libre::Schema::Result::UserForgotPassword",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_plans

Type: has_many

Related object: L<Libre::Schema::Result::UserPlan>

=cut

__PACKAGE__->has_many(
  "user_plans",
  "Libre::Schema::Result::UserPlan",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<Libre::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Libre::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_sessions

Type: has_many

Related object: L<Libre::Schema::Result::UserSession>

=cut

__PACKAGE__->has_many(
  "user_sessions",
  "Libre::Schema::Result::UserSession",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-17 15:38:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BebVwndfSVLcFpfnNsAFMg
__PACKAGE__->remove_column("password");
__PACKAGE__->add_column(
    password => {
        data_type        => "text",
        passphrase       => 'crypt',
        passphrase_class => "BlowfishCrypt",
        passphrase_args  => {
            cost        => 8,
            salt_random => 1,
        },
        passphrase_check_method => "check_password",
        is_nullable             => 0,
    },
);

use Libre::Utils;

sub new_session {
    my ($self) = @_;

    my $schema = $self->result_source->schema;

    my $session = $schema->resultset('UserSession')->search({
        user_id      => $self->id,
        valid_until  => { '>=' => \"NOW()" },
    })->next;

    if (!defined($session)) {
        $session = $self->user_sessions->create({
            api_key      => random_string(128),
            valid_until  => \"(NOW() + '1 days'::interval)",
        });
    }

    return {
        user_id => $self->id,
        name    => $self->name,
        surname => $self->surname,
        roles   => [ map { $_->name } $self->roles ],
        api_key => $session->api_key,
    };
}

sub is_donor {
    my ($self) = @_;

    return $self->user_roles->search({ role_id => 3 })->count;
}

sub is_journalist {
    my ($self) = @_;

    return $self->user_roles->search({ role_id => 2 })->count;
}

sub send_email_confirmation {
    my ($self) = @_;

    my $user_confirmation = $self->user_confirmations->create({
        token       => sha1_hex(Time::HiRes::time()),
        valid_until => \"(NOW() + '3 days'::interval)",
    });

    my $email = Libre::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@midialibre.org.br',
        subject  => "Libre - Confirmação de cadastro",
        template => get_data_section('register_confirmation.tt'),
        vars     => {
            name  => $self->name,
            token => $user_confirmation->token,
        },
    )->build_email();

    return $self->result_source->schema->resultset('EmailQueue')->create({ body => $email->as_string });
}

sub send_greetings_email {
    my ($self) = @_;

    my $email = Libre::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@midialibre.org.br',
        subject  => "Libre - Boas vindas",
        template => get_data_section('greetings.tt'),
        vars     => {
            name  => $self->name,
        },
    )->build_email();

    return $self->result_source->schema->resultset('EmailQueue')->create({ body => $email->as_string });
}

sub send_email_forgot_password {
    my ($self, $token) = @_;

    my $email = Libre::Mailer::Template->new(
        to       => $self->email,
        from     => 'no-reply@midialibre.org.br',
        subject  => "Libre - Recuperação de senha",
        template => get_data_section('forgot_password.tt'),
        vars     => {
            name  => $self->name,
            token => $token,
        },
    )->build_email();

    my $queued = $self->result_source->schema->resultset("EmailQueue")->create({ body => $email->as_string });

    return $queued;
}

__PACKAGE__->meta->make_immutable;
1;


__DATA__

@@ forgot_password.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
<td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
<p style="text-align: center;"><a href="https://midialibre.org.br/"><img src="https://gallery.mailchimp.com/af2df78bcac96c77cfa3aae07/images/c75c64c5-c400-4c18-9564-16b4a7116b03.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; align: center"></a></p>
<p><b>Olá, [% name %]. </b></p>
<p> <strong> </strong>Recebemos a sua solicitação para uma nova senha de acesso ao Libre.
É muito simples, clique no botão abaixo para trocar sua senha.</p>
  </td>
</tr>
<tr>
<td height="30"></td>
</tr>
<tr>
<td align="center" bgcolor="#ffffff" valign="top" style="padding-top:20px">
<table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:separate; border-radius:7px; margin:0">
<tbody>
<tr>
<td align="center" valign="middle"><a href="https://midialibre.org.br/account/redefinir-senha/?token=[% token %]" target="_blank" class="x_btn" style="background:#4ab957; border-radius:8px; color:#ffffff; font-family:'Montserrat',Arial,sans-serif; font-size:15px; padding:16px 24px 15px 24px; text-decoration:none; text-transform:uppercase"><strong>TROCAR MINHA SENHA</strong></a></td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td height="40"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px"><strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
  <p>Caso você não tenha solicitado esta alteração de senha, por favor desconsidere esta mensagem, nenhuma alteração foi feita na sua conta.</p>
  <p>Dúvidas? Acesse <a href="https://midialibre.org.br/ajuda" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
  Equipe Libre</strong><a href="mailto:contato@midialibre.org.br" target="_blank" style="color:#4ab957"></a></td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
  <tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Libre</strong></span></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>

</div>
</div></div>

@@ greetings.tt

<!doctype html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
<div leftmargin="0" marginheight="0" marginwidth="0" topmargin="0" style="background-color:#f5f5f5; font-family:'Montserrat',Arial,sans-serif; margin:0; padding:0; width:100%">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
<tbody>
<tr>
<td>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="600" style="border-collapse:collapse">
<tbody>
<tr>
<td height="50"></td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="2" style="background-color:rgb(255,255,255); border-radius:0 0 7px 7px; font-family:'Montserrat',Arial,sans-serif; font-size:13px; font-weight:normal; line-height:24px; padding:30px 0; text-align:center; vertical-align:top">
<table align="center" border="0" cellpadding="0" cellspacing="0" width="84%" style="border-collapse:collapse">
<tbody>
<tr>
<td align="justify" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:16px; font-weight:300; line-height:23px; margin:0">
<p style="text-align: center;"><a href="https://midialibre.org.br/"><img src="https://gallery.mailchimp.com/af2df78bcac96c77cfa3aae07/images/c75c64c5-c400-4c18-9564-16b4a7116b03.png" class="x_deviceWidth" style="border-radius:7px 7px 0 0; align: center"></a></p>
<p><b>Olá, [% name %]. </b></p>
<br></span>
</p>
<p> <strong> </strong>Agradecemos seu compromisso em valorizar a imprensa. Seu apoio é fundamental para que, juntos, jornalistas e o público criem uma mídia cada vez mais livre e democrática.</p>
<p>A partir de agora você poderá distribuir seus Libres com facilidade e segurança em toda a rede de veículos e jornalistas que utilizam nossa plataforma.</p>
<p>Em seu perfil em nosso site, você pode acompanhar o balanço de sua conta, consultar e a lista de matérias, artigos e conteúdos que você apoiou.</p>
<p>E fique de olho em nossos informes e atualizações. Libre é uma ferramenta nova e em constante evolução. Ao longo dos próximos meses vamos ampliar nossa rede de veículos, aprimorando o funcionamento e criando novas funcionalidades em nosso site.</p>
<p>Qualquer dúvida procure nosso FAQ ou escreva para nós.
<br><br>A mídia Libre conta com você!</p>
</td>
</tr>
<tr>
<td height="30"></td>
</tr>
<tr>
<td align="justify" style="color:#999999; font-size:13px; font-style:normal; font-weight:normal; line-height:16px">
<strong id="docs-internal-guid-d5013b4e-a1b5-bf39-f677-7dd0712c841b">
<p>Dúvidas? Acesse <a href="https://midialibre.org.br/ajuda/" target="_blank" style="color:#4ab957">Perguntas frequentes</a>.</p>
Equipe Libre
</strong>
<a href="mailto:contato@midialibre.org.br" target="_blank" style="color:#4ab957"></a>
</td>
</tr>
<tr>
<td height="30"></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="x_deviceWidth" width="540" style="border-collapse:collapse">
<tbody>
<tr>
<td align="center" style="color:#666666; font-family:'Montserrat',Arial,sans-serif; font-size:11px; font-weight:300; line-height:16px; margin:0; padding:30px 0px">
<span><strong>Libre</strong></span>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</div>
</div></div>
</body>
</html>

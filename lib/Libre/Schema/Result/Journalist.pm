use utf8;
package Libre::Schema::Result::Journalist;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Libre::Schema::Result::Journalist

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

=head1 TABLE: C<journalist>

=cut

__PACKAGE__->table("journalist");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_bank_account_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 cpf

  data_type: 'text'
  is_nullable: 1

=head2 address_state

  data_type: 'text'
  is_nullable: 0

=head2 address_city

  data_type: 'text'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 address_street

  data_type: 'text'
  is_nullable: 0

=head2 address_residence_number

  data_type: 'text'
  is_nullable: 0

=head2 address_complement

  data_type: 'text'
  is_nullable: 1

=head2 cellphone_number

  data_type: 'text'
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 verified_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 cnpj

  data_type: 'text'
  is_nullable: 1

=head2 vehicle

  data_type: 'boolean'
  is_nullable: 0

=head2 customer_id

  data_type: 'text'
  is_nullable: 1

=head2 customer_key

  data_type: 'text'
  is_nullable: 1

=head2 responsible_name

  data_type: 'text'
  is_nullable: 1

=head2 responsible_surname

  data_type: 'text'
  is_nullable: 1

=head2 responsible_cpf

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_bank_account_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "cpf",
  { data_type => "text", is_nullable => 1 },
  "address_state",
  { data_type => "text", is_nullable => 0 },
  "address_city",
  { data_type => "text", is_nullable => 0 },
  "address_zipcode",
  { data_type => "text", is_nullable => 0 },
  "address_street",
  { data_type => "text", is_nullable => 0 },
  "address_residence_number",
  { data_type => "text", is_nullable => 0 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "cellphone_number",
  { data_type => "text", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "verified_at",
  { data_type => "timestamp", is_nullable => 1 },
  "cnpj",
  { data_type => "text", is_nullable => 1 },
  "vehicle",
  { data_type => "boolean", is_nullable => 0 },
  "customer_id",
  { data_type => "text", is_nullable => 1 },
  "customer_key",
  { data_type => "text", is_nullable => 1 },
  "responsible_name",
  { data_type => "text", is_nullable => 1 },
  "responsible_surname",
  { data_type => "text", is_nullable => 1 },
  "responsible_cpf",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<journalist_cpf_key>

=over 4

=item * L</cpf>

=back

=cut

__PACKAGE__->add_unique_constraint("journalist_cpf_key", ["cpf"]);

=head2 C<journalist_responsible_cpf_key>

=over 4

=item * L</responsible_cpf>

=back

=cut

__PACKAGE__->add_unique_constraint("journalist_responsible_cpf_key", ["responsible_cpf"]);

=head1 RELATIONS

=head2 money_transfers

Type: has_many

Related object: L<Libre::Schema::Result::MoneyTransfer>

=cut

__PACKAGE__->has_many(
  "money_transfers",
  "Libre::Schema::Result::MoneyTransfer",
  { "foreign.journalist_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<Libre::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Libre::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_bank_account

Type: belongs_to

Related object: L<Libre::Schema::Result::UserBankAccount>

=cut

__PACKAGE__->belongs_to(
  "user_bank_account",
  "Libre::Schema::Result::UserBankAccount",
  { id => "user_bank_account_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-18 14:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uArs1OwYyY5KlgdxsRZ0zw

use WebService::PicPay;

with 'Libre::Role::Verification';
with 'Libre::Role::Verification::TransactionalActions::DBIC';

has _picpay => (
    is         => "rw",
    isa        => "WebService::PicPay",
    lazy_build => 1,
);

sub verifiers_specs {
    my $self = shift;

    return {
        update => Data::Verifier->new(
            filters => [ qw(trim) ],
            profile => {
                name => {
                    required => 0,
                    type     => "Str",
                },
                surname => {
                    required => 0,
                    type     => "Str",
                },
                address_state => {
                    required => 0,
                    type     => "Str",
                },
                address_city => {
                    required => 0,
                    type     => "Str",
                },
                address_zipcode => {
                    required => 0,
                    type     => "Str",
                },
                address_street => {
                    required => 0,
                    type     => "Str",
                },
                address_residence_number => {
                    required => 0,
                    type     => "Str",
                },
                address_complement => {
                    required => 0,
                    type     => "Str",
                },
                cellphone_number => {
                    required => 0,
                    type     => "Str",
                }
            },
        )
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        update => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my %user_params;
            defined($values{$_}) and $user_params{$_} = delete $values{$_} for qw/name surname/;

            $self->update(\%values);
            $self->user->update(\%user_params) if %user_params;
        },
    };
}

sub _build__picpay { WebService::PicPay->new() }

sub get_authlink {
    my ($self) = @_;

    if (!defined($self->customer_id) && !defined($self->customer_key)) {
        my $register = $self->_picpay->register();

        $self->_picpay->customer(
            customer_key => $register->{customer}->{customer_key},
            customer => {
                id_internal      => $self->id,
                name             => $self->user->name,
                email            => $self->user->email,
                cpf              => $self->cpf,
                cellphone_number => $self->cellphone_number,
            },
        );

        $self->update(
            {
                customer_id  => $register->{customer}->{id},
                customer_key => $register->{customer}->{customer_key},
            }
        );
    }

    return $self->_picpay->authlink(customer_key => $self->customer_key);
}

sub is_authlinked {
    my ($self) = @_;

    local $@ = undef;
    eval { $self->_picpay->userdata(customer_key => $self->customer_key) };
    if ($@) {
        return 0;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

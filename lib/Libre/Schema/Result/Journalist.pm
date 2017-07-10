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
  is_nullable: 1

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
  { data_type => "text", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-07-10 16:54:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wgcEBOEvX8mj7Nf3lRrxKg

use WebService::PicPay;

has _picpay => (
    is         => "rw",
    isa        => "WebService::PicPay",
    lazy_build => 1,
);

sub _build__picpay { WebService::PicPay->new() }

sub get_authlink {
    my ($self) = @_;

    if (!defined($self->customer_id) && !defined($self->customer_key)) {
        my $register = $self->_picpay->register();

        $self->update(
            {
                customer_id  => $register->{customer}->{id},
                customer_key => $register->{customer}->{customer_key},
            }
        );
    }

    return $self->_picpay->authlink(customer_key => $self->customer_key);
}

__PACKAGE__->meta->make_immutable;

1;

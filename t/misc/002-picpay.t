use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

use_ok("WebService::PicPay");

my $picpay = WebService::PicPay->new();
isa_ok $picpay, "WebService::PicPay";

ok (my $register = $picpay->register(), 'register');
is (ref($register), "HASH");
is (ref($register->{customer}), "HASH");

my $customer_id  = $register->{customer}->{id};
my $customer_key = $register->{customer}->{customer_key};

ok (defined($customer_id),  'customer id');
ok (defined($customer_key), 'customer key');

ok (my $authlink = $picpay->authlink(customer_key => $customer_key), 'authlink');
is (ref($authlink), "HASH");
is (ref($authlink->{picpayconnect}), "HASH");
ok (defined($authlink->{picpayconnect}->{authurl}), 'auth url');

ok (my $user_data = $picpay->userdata(customer_key => $customer_key), 'user data');
is (ref($user_data->{picpayuser}), "HASH", 'picpayuser');
ok (defined($user_data->{picpayuser}->{name}), 'picpay name');

done_testing();


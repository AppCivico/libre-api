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
ok (defined($register->{customer}->{id}), 'customer id');
ok (defined($register->{customer}->{customer_key}), 'customer key');

ok (my $authlink = $picpay->authlink(customer_key => $register->{customer}->{customer_key}), 'authlink');
is (ref($authlink), "HASH");
is (ref($authlink->{picpayconnect}), "HASH");
ok (defined($authlink->{picpayconnect}->{authurl}), 'auth url');

done_testing();


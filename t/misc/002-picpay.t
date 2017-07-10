use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

use_ok("WebService::PicPay");

my $picpay = WebService::PicPay->new();
isa_ok $picpay, "WebService::PicPay";

ok (my $register = $picpay->register(), "register");
ok (defined($register->{customer}->{id}), "customer id");
ok (defined($register->{customer}->{customer_key}), "customer key");

done_testing();


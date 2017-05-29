use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

ok(is_test(), 'running in test suite');

is (get_libre_api_url_for("/api"), "http://localhost/api", 'get libre api url');

is (truncate_money(345.84615384615385), "345.84");
is (truncate_money(3), 3);
is (truncate_money(3.80), 3.8);
is (truncate_money("9.40000"), 9.4);
is (truncate_money(0.12567), 0.12);
is (truncate_money(0.0), 0);

is ($@, "", "no exception yet");
eval { truncate_money(-126.53791782) };
ok ($@ =~ m{^invalid number}, "no negative numbers");

done_testing();


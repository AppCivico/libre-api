use strict;
use warnings;

use Libre;

my $app = Libre->apply_default_middlewares(Libre->psgi_app);
$app;


use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

db_transaction {
    create_donor;

    ok(my $user = $schema->resultset("User")->find(stash "donor.id"), 'get user');
    is($user->verified, 0, 'user not confirmed');

    rest_post "/api/login/confirm",
        name => 'confirm with fake token',
        code => 200,
        [ token => "aaaaaaaaaaaa" ],
    ;

    is($user->verified, 0, 'user still not confirmed');

    ok(
        my $user_confirmation = $schema->resultset("UserConfirmation")->search({ user_id => $user->id })->next,
        'get_confirmation token',
    );

    rest_post "/api/login/confirm",
        name  => "confirm account",
        code  => 200,
        params => {
            token => $user_confirmation->token,
        },
    ;

    is ($user->discard_changes->verified, 1, "user confirmed");

};

done_testing();
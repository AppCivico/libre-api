use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

db_transaction {
    my $email    = fake_email()->();
    my $password = "foobarquux1";

    create_donor(
        email    => $email,
        password => $password,
    );

    my $user = $schema->resultset("User")->find(stash 'donor.id');

    rest_post "/api/login",
        name  => "login",
        code  => 200,
        stash => "l1",
        [
            email    => $email,
            password => $password,
        ],
    ;

    stash_test 'l1' => sub {
        my $res = shift;

        is($res->{user_id}, $user->id, 'user_id');
    };

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => $user->email,
        },
    ;

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => $user->email,
        },
    ;

    rest_post "/api/login/forgot_password",
        name   => "forgot password",
        code   => 200,
        params => {
            email => $user->email,
        },
    ;

    is (
        $schema->resultset("UserForgotPassword")->search({
            user_id     => $user->id,
            valid_until => { '>=' => \'NOW()' },
        })->count,
        1,
        'only one token valid',
    );

    my $forgot_password = $schema->resultset('UserForgotPassword')->search({
        user_id     => $user->id,
        valid_until => { '>=' => \'NOW()' },
    })->next;

    my $token = $forgot_password->token;
    is (length $token, 40, 'token has 40 chars');

    my $new_password = random_string(8);

    $forgot_password->update({
        valid_until => \"(NOW() - '1 minutes'::interval)",
    });

    rest_post "/api/login/forgot_password/reset/$token",
        name    => "reset password with invalid token returns ok",
        code    => 200,
        params  => {
            new_password => $new_password,
        },
    ;

    $forgot_password->update({
        valid_until => \"(NOW() + '1 days'::interval)",
    });

    rest_post "/api/login/forgot_password/reset/$token",
        name   => "reset password",
        code   => 200,
        params => {
            new_password => $new_password,
        },
    ;

    ok (!defined($schema->resultset('UserForgotPassword')->search({ token => $token })->next), "token expired");

    rest_post "/api/login",
        name  => "login with new password",
        code  => 200,
        [
            email    => $email,
            password => $new_password,
        ],
    ;
};

done_testing();


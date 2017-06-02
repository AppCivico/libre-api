use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

db_transaction {
    create_donor(
        password => "saveh123"
    );

    ok (my $user = $schema->resultset("User")->find(stash 'user.id'));

    # Login com a senha correta.
    rest_post '/api/login',
        name  => 'first login',
        code  => 200,
        stash => 'l1',
        [
            email    => $user->email,
            password => "saveh123",
        ],
    ;

    stash_test 'l1' => sub {
        my $res = shift;

        is ($res->{user_id}, $user->id, 'user id');
    };

    # Vou chamar o forgot_password três vezes. Teoricamente ele cria três tokens, mas esses três tokens não
    # podem ser válidos simultaneamente (por segurança).
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

    # Criei três tokens, mas apenas um deve ser válido.
    is (
        $schema->resultset("UserForgotPassword")->search({
            user_id     => $user->id,
            valid_until => { '>=' => \'NOW()' },
        })->count,
        1,
        'only one token valid',
    );

    # O token retornado realmente pertence ao devido usuario?
    my $forgot_password = $schema->resultset('UserForgotPassword')->search({
        user_id     => $user->id,
        valid_until => { '>=' => \'NOW()' },
    })->next;

    my $token = $forgot_password->token;
    is (length $token, 40, 'token has 40 chars');

    # Resetando o password.
    my $new_password = random_string(8);

    # Não é possível utilizar um token expirado.
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

    # Agora volto o valor do valid_until e essa troca tem que funcionar.
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

    # O token deve ter expirado da tabela.
    ok (!defined($schema->resultset('UserForgotPassword')->search({ token => $token })->next), "token expired");

    # Agora eu devo conseguir logar com a nova senha.
    rest_post '/api/login',
        name   => "login with new password",
        code   => 200,
        stash  => 'login',
        params => {
            email    => $user->email,
            password => $new_password,
        },
    ;


};

done_testing();


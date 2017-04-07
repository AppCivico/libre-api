use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    my $email = fake_email()->();
    my $password = "foobarquux1";

    create_journalist(
        email    => $email,
        password => $password,
    );

    # Se eu entrar com um email e senha inválidos, deve dar erro.
    rest_post "/v1/login",
        name    => "wrong login",
        is_fail => 1,
        [
            email    => $email,
            password => "juniorFVOX",
        ],
    ;

    rest_post "/v1/login",
        name  => "login",
        code  => 200,
        stash => "l1",
        [
            email    => $email,
            password => $password,
        ],
    ;

    # A session foi criada?
    ok (
        my $user_session = $schema->resultset("UserSession")->search(
            {
                "user.id"   => stash "journalist.id",
                valid_until => { ">=" => \"NOW()" }
            },
            { join => "user" },
        )->next,
        "created user session",
    );

    # A resposta foi a esperada?
    is_deeply(
        stash "l1",
        {
            api_key => $user_session->api_key,
            roles   => ["journalist"],
            user_id => $user_session->user->id,
        },
    );
};

done_testing();
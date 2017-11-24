use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    my $email = fake_email()->();

    rest_post "/api/register/donor",
        is_fail => 1,
        params  => {
            email    => fake_email()->(),
            password => "12345",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    rest_post "/api/register/donor",
        stash               => "d1",
        automatic_load_item => 0,
        params              => {
            email    => $email,
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    is($schema->resultset("EmailQueue")->count, 1, 'email queued');

    is (
        $schema->resultset("Donor")->find(stash "d1.id")->user->email,
        $email,
        "created user and donor",
    );

    # Deve ser obriǵatório o CPF
    rest_post "/api/register/donor",
        is_fail      => 1,
        params              => {
            email    => $email,
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    # Não deve ser possível cadastrar o mesmo email.
    rest_post "/api/register/donor",
        is_fail => 1,
        params  => {
            email    => $email,
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    # Telefone deve ser opcional, mas não pode ser inválido.
    rest_post "/api/register/donor",
        automatic_load_item => 0,
        params              => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    rest_post "/api/register/donor",
        is_fail => 1,
        params  => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => "+551398200 23",
        },
    ;

    # Registro com plano.
    rest_post "/api/register/donor",
        name  => 'register user with plan',
        stash => 'donor',
        automatic_load_item => 0,
        params => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            cpf      => random_cpf(),
            phone    => fake_digits("+551198#######")->(),
            amount   => 2000,
        },
    ;

    ok( my $user_plan = $schema->resultset('UserPlan')->search( { 'me.user_id' => stash 'donor.id' } )->next, 'created plan' );
    is( $user_plan->get_column('amount'),            2000, 'amount=2000' );
    is( $user_plan->get_column('first_korduv_sync'), 1,    'first_korduv_sync=true' );
    is( $user_plan->get_column('canceled'),          0,    'canceled=false' );
};

done_testing();

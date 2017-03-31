use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model("DB");

db_transaction {
    my $email = fake_email()->();

    rest_post "/v1/register/donor",
        stash               => "r1",
        automatic_load_item => 0,
        params              => {
            email    => $email,
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    # Não deve ser possível cadastrar o mesmo email.
    rest_post "/v1/register/donor",
        is_fail => 1,
        params  => {
            email    => $email,
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    # Telefone deve ser opcional, mas não pode ser inválido.
    rest_post "/v1/register/donor",
        automatic_load_item => 0,
        params              => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            phone    => fake_digits("+551198#######")->(),
        },
    ;

    rest_post "/v1/register/donor",
        is_fail => 1,
        params  => {
            email    => fake_email()->(),
            password => "fooquxbar1",
            name     => fake_first_name()->(),
            surname  => fake_surname()->(),
            phone    => "+551398200 23",
        },
    ;
};

done_testing();

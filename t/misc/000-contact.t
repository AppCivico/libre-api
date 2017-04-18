use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;

my $schema = Libre->model('DB');

db_transaction {
    rest_post '/api/contact',
        name   => "contact",
        stash  => 'c1',
        code   => 200,
        params => {
            name    => fake_name()->(),
            company => fake_name()->(),
            subject => fake_sentences(fake_int(1, 3))->(),
            phone   => fake_digits("+55119#######")->(),
            email   => fake_email()->(),
            message => fake_paragraphs(fake_int(1, 3))->(),
        },
    ;

    stash_test 'c1' => sub {
        my $res = shift;

        ok ($schema->resultset('EmailQueue')->find($res->{id}), 'email queued');
    };
};

done_testing();


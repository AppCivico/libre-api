use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Libre::Test::Further;
use Libre::Utils;

my $schema = Libre->model('DB');

db_transaction {
    use_ok 'Libre::Worker::Email';
    use_ok 'Libre::Mailer::Template';

    my $worker = new_ok('Libre::Worker::Email', [ schema => $schema ]);

    ok ($worker->does('Libre::Worker'), 'Libre::Worker::Email does Libre::Worker');

    is ($schema->resultset('EmailQueue')->count, "0", "there is no email queued yet");

    # Criando um email.
    my $email = Libre::Mailer::Template->new(
        to       => fake_email()->(),
        from     => fake_email()->(),
        subject  => fake_sentences(1)->(),
        template => fake_paragraphs(3)->(),
        vars     => {},
    )->build_email();

    isa_ok ($email, "MIME::Lite", "built mail");

    ok (
        $schema->resultset("EmailQueue")->create({
            body => $email->as_string,
        }),
        "email queued",
    );

    ok ($worker->run_once(), 'run once');

    is ($schema->resultset('EmailQueue')->count, "0", "out of queue");
};

done_testing();


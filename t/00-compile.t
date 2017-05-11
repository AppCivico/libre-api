use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.056

use Test::More;

plan tests => 51 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

my @module_files = (
    'Data/Verifier.pm',
    'Libre.pm',
    'Libre/Controller/API.pm',
    'Libre/Controller/API/Contact.pm',
    'Libre/Controller/API/Donor.pm',
    'Libre/Controller/API/Donor/CreditCard.pm',
    'Libre/Controller/API/Donor/Plan.pm',
    'Libre/Controller/API/Journalist.pm',
    'Libre/Controller/API/Journalist/Donation.pm',
    'Libre/Controller/API/Login.pm',
    'Libre/Controller/API/Register.pm',
    'Libre/Controller/API/Register/Donor.pm',
    'Libre/Controller/API/Register/Journalist.pm',
    'Libre/Controller/HttpCallback.pm',
    'Libre/Controller/Root.pm',
    'Libre/Data/Manager.pm',
    'Libre/Data/Visitor.pm',
    'Libre/Mailer.pm',
    'Libre/Mailer/Template.pm',
    'Libre/Model/DB.pm',
    'Libre/Model/Flotum.pm',
    'Libre/Role/Verification.pm',
    'Libre/Role/Verification/TransactionalActions.pm',
    'Libre/Role/Verification/TransactionalActions/DBIC.pm',
    'Libre/Schema.pm',
    'Libre/Schema/Result/BankInstitution.pm',
    'Libre/Schema/Result/City.pm',
    'Libre/Schema/Result/Credit.pm',
    'Libre/Schema/Result/Donation.pm',
    'Libre/Schema/Result/Donor.pm',
    'Libre/Schema/Result/EmailQueue.pm',
    'Libre/Schema/Result/HttpCallbackToken.pm',
    'Libre/Schema/Result/Journalist.pm',
    'Libre/Schema/Result/Plan.pm',
    'Libre/Schema/Result/Role.pm',
    'Libre/Schema/Result/State.pm',
    'Libre/Schema/Result/User.pm',
    'Libre/Schema/Result/UserBankAccount.pm',
    'Libre/Schema/Result/UserPlan.pm',
    'Libre/Schema/Result/UserRole.pm',
    'Libre/Schema/Result/UserSession.pm',
    'Libre/Schema/ResultSet/Donation.pm',
    'Libre/Schema/ResultSet/Donor.pm',
    'Libre/Schema/ResultSet/HttpCallbackToken.pm',
    'Libre/Schema/ResultSet/Journalist.pm',
    'Libre/Schema/ResultSet/UserPlan.pm',
    'Libre/SchemaConnected.pm',
    'Libre/Types.pm',
    'Libre/Utils.pm',
    'Libre/Worker.pm',
    'Libre/Worker/Email.pm'
);



# no fake home requested

my @switches = (
    -d 'blib' ? '-Mblib' : '-Ilib',
);

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    diag('Running: ', join(', ', map { my $str = $_; $str =~ s/'/\\'/g; q{'} . $str . q{'} }
            $^X, @switches, '-e', "require q[$lib]"))
        if $ENV{PERL_COMPILE_TEST_DEBUG};

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, @switches, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    shift @_warnings if @_warnings and $_warnings[0] =~ /^Using .*\bblib/
        and not eval { require blib; blib->VERSION('1.01') };

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found')
    or diag 'got warnings: ', ( Test::More->can('explain') ? Test::More::explain(\@warnings) : join("\n", '', @warnings) ) if $ENV{AUTHOR_TESTING};



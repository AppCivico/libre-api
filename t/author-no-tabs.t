
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    print qq{1..0 # SKIP these tests are for testing by the author\n};
    exit
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Data/Verifier.pm',
    'lib/Libre.pm',
    'lib/Libre/Controller/API.pm',
    'lib/Libre/Controller/API/Contact.pm',
    'lib/Libre/Controller/API/Donor.pm',
    'lib/Libre/Controller/API/Donor/CreditCard.pm',
    'lib/Libre/Controller/API/Donor/Plan.pm',
    'lib/Libre/Controller/API/Journalist.pm',
    'lib/Libre/Controller/API/Journalist/Donation.pm',
    'lib/Libre/Controller/API/Login.pm',
    'lib/Libre/Controller/API/Register.pm',
    'lib/Libre/Controller/API/Register/Donor.pm',
    'lib/Libre/Controller/API/Register/Journalist.pm',
    'lib/Libre/Controller/HttpCallback.pm',
    'lib/Libre/Controller/Root.pm',
    'lib/Libre/Data/Manager.pm',
    'lib/Libre/Data/Visitor.pm',
    'lib/Libre/Mailer.pm',
    'lib/Libre/Mailer/Template.pm',
    'lib/Libre/Model/DB.pm',
    'lib/Libre/Model/Flotum.pm',
    'lib/Libre/Role/Verification.pm',
    'lib/Libre/Role/Verification/TransactionalActions.pm',
    'lib/Libre/Role/Verification/TransactionalActions/DBIC.pm',
    'lib/Libre/Schema.pm',
    'lib/Libre/Schema/Result/BankInstitution.pm',
    'lib/Libre/Schema/Result/City.pm',
    'lib/Libre/Schema/Result/Credit.pm',
    'lib/Libre/Schema/Result/Donation.pm',
    'lib/Libre/Schema/Result/Donor.pm',
    'lib/Libre/Schema/Result/EmailQueue.pm',
    'lib/Libre/Schema/Result/HttpCallbackToken.pm',
    'lib/Libre/Schema/Result/Journalist.pm',
    'lib/Libre/Schema/Result/Plan.pm',
    'lib/Libre/Schema/Result/Role.pm',
    'lib/Libre/Schema/Result/State.pm',
    'lib/Libre/Schema/Result/User.pm',
    'lib/Libre/Schema/Result/UserBankAccount.pm',
    'lib/Libre/Schema/Result/UserPlan.pm',
    'lib/Libre/Schema/Result/UserRole.pm',
    'lib/Libre/Schema/Result/UserSession.pm',
    'lib/Libre/Schema/ResultSet/Donation.pm',
    'lib/Libre/Schema/ResultSet/Donor.pm',
    'lib/Libre/Schema/ResultSet/HttpCallbackToken.pm',
    'lib/Libre/Schema/ResultSet/Journalist.pm',
    'lib/Libre/Schema/ResultSet/UserPlan.pm',
    'lib/Libre/SchemaConnected.pm',
    'lib/Libre/Types.pm',
    'lib/Libre/Utils.pm',
    'lib/Libre/Worker.pm',
    'lib/Libre/Worker/Email.pm',
    't/00-compile.t',
    't/author-critic.t',
    't/author-eol.t',
    't/author-no-tabs.t',
    't/donor/000-register.t',
    't/donor/001-login.t',
    't/donor/002-credit-card.t',
    't/donor/003-plan.t',
    't/donor/004-donation.t',
    't/journalist/000-register.t',
    't/journalist/001-login.t',
    't/journalist/002-credits.t',
    't/lib/Libre/Test/Further.pm',
    't/misc/000-contact.t',
    't/release-dist-manifest.t',
    't/release-distmeta.t',
    't/release-kwalitee.t',
    't/release-unused-vars.t',
    't/worker/000-email.t'
);

notabs_ok($_) foreach @files;
done_testing;

use inc::Module::Install;

perl_version '5.008';
all_from     'lib/Business/Qiwi.pm';

requires 'Moose';
requires 'MooseX::Declare';
requires 'MooseX::Types';
requires 'XML::LibXML';
requires 'LWP::UserAgent';
requires 'Digest::MD5';
requires 'Crypt::CBC';
requires 'Crypt::DES_EDE3';

test_requires 'Test::More';

WriteAll;

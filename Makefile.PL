use inc::Module::Install;

name         'Business-Qiwi';
perl_version '5.008';
all_from     'lib/Business/Qiwi.pm';

requires 'Moose'           => '0.75';
requires 'MooseX::Declare' => '0.22';
requires 'MooseX::Types'   => '0.10';
requires 'XML::LibXML'     => '1.66';
requires 'LWP::UserAgent';

test_requires 'Test::More';

recommends 'Digest::MD5';
recommends 'Crypt::TripleDES' => '0.24';

WriteAll;

use inc::Module::Install;

name         'Business::Qiwi';
perl_version '5.008';
all_from     'lib/Business/Qiwi.pm';

requires 'Moose'          => '0.69';
requires 'XML::LibXML'    => '1.66';
requires 'LWP::UserAgent' => '5.816';

test_requires 'Test::More' => '0.8';

recommends 'Digest::MD5'      => '0';
recommends 'Crypt::TripleDES' => '0.24';

WriteAll;
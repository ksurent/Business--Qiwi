use Test::More tests => 1;
use Test::Mock::Class 'mock_anon_class';

my $response_xml_ok = <<XML_OK;
<?xml version="1.0" encoding="utf-8" ?>
<response>
    <result-code fatal="false">0</result-code>
</response>
XML_OK

my $response_xml_nok = <<XML_NOK;
<?xml version="1.0" encoding="utf-8" ?>
<response>
    <result-code fatal="false">298</result-code>
</response>
XML_NOK

my $mock = mock_anon_class 'Business::Qiwi::Invoice';

my $invoice = $mock->new_object(
    to => ,
);
$invoice->create_request;

is $invoice->_raw_request, '', 'request creation ok';

$mock->mock_return(
    '_raw_response',
    $response_xml_ok,
    args => [],
);
$invoice->send_request

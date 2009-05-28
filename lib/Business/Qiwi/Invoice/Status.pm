use MooseX::Declare;

class Business::Qiwi::Invoice::Status extends Business::Qiwi::Request {
    use Business::Qiwi::MooseSubtypes qw(InvoicesList);

    has +request_type => ( default => 33, );

    has invoice => ( is => 'rw', isa => InvoicesList, coerce => 1, required => 1, );

    augment create_request() {
        my $invoices = $self->_create_simple_node('bills-list');
        $invoices->appendChild( $self->_create_simple_node('bill', undef, {id => $_}) ) foreach @{ $self->invoice };
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($invoices);
        
        $xml
    }

    augment parse_raw_response() {
        [map +{id     => $_->getAttribute('id'),
               status => $_->getAttribute('status'),},
             $self->_xml_response->find('/response/bills-list/bill')->get_nodelist]
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Bill::Status - Get status of given bill

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

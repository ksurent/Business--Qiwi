use MooseX::Declare;

class Business::Qiwi::Payment::Status extends Business::Qiwi::Request {
    has '+request_type' => ( default => 10, );

    has 'txns' => ( is => 'rw', isa => 'Business::Qiwi::MooseSubtypes::TxnsList', coerce => 1, required => 1, );

    augment create_request => sub {
        my $self = shift;
        
        my $status = $self->_create_simple_node('status', undef, {count => scalar @{$self->txns}});
        foreach( @{ $self->txns } ) {
            my $payment = $self->_create_simple_node('payment');
            $payment->appendChild( $self->_create_simple_node('transaction-number', $_) );
            $status->appendChild($payment)
        }
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($status);
        
        $xml
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        return {
            map {
                my $payment_data = $_->getAttribute('final-status') eq 'true'
                    ? {code  => $_->getAttribute('result-code'),
                       fatal => ($_->getAttribute('fatal-error') eq 'true') ? 1 : 0}
                    : {current => $_->getAttribute('status'),};
                
                $_->getAttribute('transaction-number') => $payment_data
            }
            $self->_xml_response->find('/response/payment')->get_nodelist
        }
    };
};

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Payment::Status - Get status of given payment

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use MooseX::Declare;

class Business::Qiwi::Payment::Incoming extends Business::Qiwi::Request {
    use Business::Qiwi::MooseSubtypes qw(Date);

    has +request_type => ( default => 31, );

    has since => ( is => 'rw', isa => Date, required => 1, );
    has to    => ( is => 'rw', isa => Date, required => 1, );

    augment create_request() {
        my $date_since = $self->_create_extra_node('date-from', $self->since);
        my $date_to = $self->_create_extra_node('date-to', $self->to);
        
        my $from = $self->_create_simple_node('from');
        $from->appendChild( $self->_create_simple_node('service-id', 0) );
        $from->appendChild( $self->_create_simple_node('account-number', 0) );
        
        my $to = $self->_create_simple_node('to');
        $to->appendChild( $self->_create_simple_node('service-id', 0) );
        $to->appendChild( $self->_create_simple_node('account-number', 0) );
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($_) foreach $date_since, $date_to, $from, $to;
        
        $xml
    }

    augment parse_raw_response() {
        return [
            map +{id         => $_->findvalue('./transaction-number'),
                  date       => $_->findvalue('./txn-date'),
                  status_id  => $_->findvalue('./status-id'),
                  status_msg => $_->findvalue('./status-msg'),
                  result_msg => $_->findvalue('./result-msg'),
                  from       => $_->findvalue('./from-agt'),
                  to         => $_->findvalue('./to-agt'),
                  amount     => $_->findvalue('./to-amount'),
                  comment    => $_->findvalue('./comment'),},
            $self->_xml_response->find('/response/payments-list/payment')->get_nodelist
        ]
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Payment::Incoming - Get payments made to you

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

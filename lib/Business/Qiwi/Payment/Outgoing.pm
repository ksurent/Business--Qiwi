use MooseX::Declare;

class Business::Qiwi::Payment::Outgoing extends Business::Qiwi::Request {
    use Business::Qiwi::MooseSubtypes qw(Date);

    has +request_type => ( default => 8, );

    has since => ( is => 'rw', isa => Date, required => 1, );
    has to    => ( is => 'rw', isa => Date, required => 1, );

    augment create_request() {
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_extra_node('date-from', $self->since) );
        $xml->appendChild( $self->_create_extra_node('date-to', $self->to) );
        
        $xml
    }

    augment parse_raw_response() {
        [map +{status   => $_->findvalue('./status'),
               txn_id   => $_->findvalue('./transaction-number'),
               txn_date => $_->findvalue('./txn-date'),
               amount   => $_->findvalue('./to/amount'),
               to       => $_->findvalue('./to/account-number'),
               service  => $_->findvalue('./to/service-id'),},
            $self->_xml_response->find('/response/payments-list/payment')->get_nodelist]
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Report - Get information of made payments by you

=head1 SYNOPSIS

    $qiwi->get_report(since => '01.01.2009', to => '31.01.2009');
    foreach( keys %{ $qiwi->result } ) {
        printf "Transaction: ID: %d, DATE: %s\n", $_->{txn_id}, $_->{txn_date};
        printf "Payee: ID: %d, SERVICE: %d\n", $_->{to}, $_->{service};
        printf "Amount: %.2f\n", $_->{amount}
        printf "Status: %d\n", $_->{status};
    }

=head1 DESCRIPTION

=head2 Constructor

=head2 Returns

ArrayRef[HashRef]. Each HashRef represents one payment made and consists of fields:

=over 4

=item * txn_id => Int

Transaction number

=item * txn_date => Str

Transaction initialization date

=item * status => Int

Transaction complete status

=item * to => Str

Payee account id

=item * service => Int

Payee service id

=item * amount => Num

Amount of credits paid

=back

=cut

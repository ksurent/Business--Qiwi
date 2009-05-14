use MooseX::Declare;

class Business::Qiwi::Payment extends Business::Qiwi::Request {
    has '+request_type' => ( default => 10, );

    has to         => ( is => 'rw', isa => 'Str', required => 1, );
    has service    => ( is => 'rw', isa => 'Int', required => 1, );
    has amount     => ( is => 'rw', isa => 'Num', required => 1, );
    has comment    => ( is => 'rw', isa => 'Str', required => 1, );
    has id         => ( is => 'rw', isa => 'Int', required => 1, );
    has receipt_id => ( is => 'rw', isa => 'Int', default => int(rand 999999), );

    augment create_request => sub {
        my $self = shift;
        
        my $from = $self->_create_simple_node('from');
        $from->appendChild( $self->_create_simple_node('amount', $self->amount) );
        
        my $to = $self->_create_simple_node('to');
        $to->appendChild( $self->_create_simple_node('amount', $self->amount) );
        $to->appendChild( $self->_create_simple_node('service-id', $self->service) );
        $to->appendChild( $self->_create_simple_node('account-number', $self->to) );
        
        my $receipt = $self->_create_simple_node('receipt');
        $receipt->appendChild( $self->_create_simple_node('receipt-number', $self->receipt_id) );
        $receipt->appendChild(
            $self->_create_simple_node(
                'datetime',
                sub{local@_=reverse((localtime)[0..5]);$_[0]+=1900;$_[1]+=1;join '',@_}->()
            )
        );
        
        my $payment = $self->_create_simple_node('payment');
        $payment->appendChild( $self->_create_simple_node('transaction-number', $self->id) );
        $payment->appendChild( $self->_create_extra_node('comment', $self->comment) );
        $payment->appendChild($_) foreach $from, $to, $receipt;
        
        my $auth = $self->_create_simple_node('auth', undef, {count => 1, 'to-amount' => $self->amount});
        $auth->appendChild($payment);
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($auth);
        
        $xml
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        my $payment = $self->_xml_response->find('/response/payment[1]')->shift;
        
        return {txn    => $payment->getAttribute('transaction-number'),
                status => $payment->getAttribute('status'),
                code   => $payment->getAttribute('result-code'),}
    };
};

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Payment - Pay for services or bills

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

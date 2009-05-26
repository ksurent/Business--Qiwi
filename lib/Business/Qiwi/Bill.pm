use MooseX::Declare;

class Business::Qiwi::Bill extends Business::Qiwi::Request {
    use MooseX::Types::Moose qw(Int Num Str Bool);

    has +request_type => ( default => 30, );

    has amount          => ( is => 'rw', isa  => Num, required => 1, );
    has to              => ( is => 'rw', isa  => Str, required => 1, );
    has txn             => ( is => 'rw', isa  => Str, required => 1, );
    has comment         => ( is => 'rw', isa  => Str, required => 1, );
    has sms_notify      => ( is => 'rw', isa  => Bool, default => 0, );
    has call_notify     => ( is => 'rw', isa  => Bool, default => 0, );
    has confirm_timeout => ( is => 'rw', isa  => Int, default => 30 * 24, );

    augment create_request() {
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_extra_node('amount', $self->amount) );
        $xml->appendChild( $self->_create_extra_node('to-account', $self->to) );
        $xml->appendChild( $self->_create_extra_node('trm-id', $self->txn) );
        $xml->appendChild( $self->_create_extra_node('comment', $self->comment) );
        $xml->appendChild( $self->_create_extra_node('ALARM_SMS', $self->sms_notify) );
        $xml->appendChild( $self->_create_extra_node('ACCEPT_CALL', $self->call_notify) );
        $xml->appendChild( $self->_create_extra_node('ltime', $self->confirm_timeout) );
        
        $xml
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Bill - Create bills to be payed by other agents

=head1 SYNOPSIS

    $qiwi->create_bill(
        to              => $customed_id,
        amount          => $order_sum,
        txn             => $txn_id,
        comment         => 'Your comment for this bill',
        sms_notify      => $,
        call_notify     => ,
        confirm_timeout => ,
    )

=head1 DESCRIPTION

=head2 Constructor

=over 4

=item * amount => Num

Amount to be payed

=item * to => Str

Payer account id

=item * txn => Int

Unique transaction id (used to get bill's status later)

=item * comment => Str

Comment for bill

=item * sms_notify => Bool I<(optional, default is false)>

Should QIWI send message to payer about he is billed by you?

NOTE: notifications are not free!

=item * call_notify => Bool I<(optional, default is false)>

Should QIWI make an automatic voice call to payer about he is billed by you?

NOTE: notifications are not free!

=item * confirm_timeout => Int I<(optional, default is 30 days)>

Amount of hours payer have to confirm to pay this bill

=back

=head2 Returns

Nothing. Check result-code

=cut

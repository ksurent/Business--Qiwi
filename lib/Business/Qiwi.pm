{
    package Business::Qiwi;
    our $VERSION = '0.01';
}

use MooseX::Declare;

class Business::Qiwi {
    use MooseX::Types::Moose qw(Num Int Str Bool HashRef Object);
    use Business::Qiwi::MooseSubtypes qw(Date EntriesList IdsList TxnsList InvoicesList);

    has trm_id   => ( is => 'rw', isa => Str, required => 1, );
    has password => ( is => 'rw', isa => Str, required => 1, );
    has serial   => ( is => 'rw', isa => Str, required => 1, );
#    has cipher   => ( is => 'rw', isa => Bool, default => 0, );

    has _request_instance => (
        is         => 'rw',
        isa        => Object,
        lazy_build => 1,
        handles    => {
            is_fatal   => 'fatal',
            is_success => 'success',
            res_code   => 'code',
#            res_msg    => 'message',
        },
    );

    method create_invoice(Num :$amount, Str :$to, Str :$txn, Str :$comment, Bool :$sms_notify?, Bool :$call_notify?, Int :$confirm_time?) {
        return $self->_instantiate_and_execute(
            'Invoice',
            {
                amount       => $amount,
                to           => $to,
                txn          => $txn,
                comment      => $comment,
                call_notify  => $call_notify,
                sms_notify   => $sms_notify,
                confirm_time => $confirm_time,
            }, 
        )
    }

    method get_invoice_status(Int|InvoicesList :$invoice) {
        return $self->_instantiate_and_execute(
            'Invoice::Status',
            {
                invoice => $invoice,
            },
        )
    }

    method accept_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        return $self->_instantiate_and_execute(
            'Invoice::Accept',
            {
                defined $qiwi_txn_id
                    ? (qiwi_txn_id => $qiwi_txn_id)
                    : (trm_txn_id  => $trm_txn_id)
            },
        )
    }

#    before accept_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
#        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
#            if not defined $qiwi_txn_id and not defined $trm_txn_id
#    }

    method reject_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        return $self->_instantiate_and_execute(
            'Invoice::Reject',
            {
                defined $qiwi_txn_id
                    ? (qiwi_txn_id => $qiwi_txn_id)
                    : (trm_txn_id  => $trm_txn_id)
            },
        )
    }

#    before reject_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
#        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
#            if not defined $qiwi_txn_id and not defined $trm_txn_id
#    }

    method pay(Str :$to, Int :$service, Num :$amount, Str :$comment, Int :$id, Int :$receipt_id?) {
        return $self->_instantiate_and_execute(
            'Payment',
            {
                to         => $to,
                service    => $service,
                amount     => $amount,
                comment    => $comment,
                id         => $id,
                receipt_id => $receipt_id,
            },
        )
    }

    method get_payment_status(Int|TxnsList :$txn) {
        return $self->_instantiate_and_execute(
            'Payment::Status',
            {
                txn => $txn,
            },
        )
    }

    method get_incoming_payments(Date :$since, Date :$to) {
        return $self->_instantiate_and_execute(
            'Payment::Incoming',
            {
                since => $since,
                to    => $to,
            },
        )
    }

    method get_phonebook() {
        return $self->_instantiate_and_execute('PhoneBook')
    }

    method add_to_phonebook(HashRef|EntriesList :$entry) {
        return $self->_instantiate_and_execute(
            'PhoneBook::Add',
            {
                entry => $entry,
            },
        )
    }

    method delete_from_phonebook(Int|IdsList :$id) {
        return $self->_instantiate_and_execute(
            'PhoneBook::Delete',
            {
                id => $id,
            },
        )
    }

    method register(Str :$password, Str :$phone) {
       return $self->_instantiate_and_execute(
            'Register',
            {
                password => $password,
                phone    => $phone,
            },
        )
    }

    method confirm_registration(Str :$password, Str :$phone, Str :$confirm) {
        return $self->_instantiate_and_execute(
            'Register',
            {
                password => $password,
                phone    => $phone,
                confirm  => $confirm,
            },
        )
    }

    method get_report(Date :$since, Date :$to) {
        return $self->_instantiate_and_execute(
            'Report',
            {
                since => $since,
                to    => $to,
            },
        )
    }

    method get_balance() {
        return $self->_instantiate_and_execute('Balance')
    }

    method _instantiate(Str $subclass!, HashRef $args = {}) {
        $self->_clear_request_instance;

        my $class = "Business::Qiwi::$subclass";

        my $is_loaded = eval "require $class; 1";
        Moose->throw_error("Subclass $class can not be loaded: $@") unless $is_loaded;
        
        $self->_request_instance(
            $class->new(
                trm_id   => $self->trm_id,
                serial   => $self->serial,
                password => $self->password,
#                cipher   => $self->cipher,
                %$args,
            )
        )
    }

    method _execute() {
        return unless $self->_has_request_instance;

        $self->_request_instance->create_request;
        $self->_request_instance->send_request;
        $self->_request_instance->parse_raw_response;
        $self->_request_instance->result
    }

    method _instantiate_and_execute(Str $subclass!, HashRef $args = {}) {
        $self->_instantiate($subclass, $args);
        $self->_execute
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi - Perl API to QIWI payment system

=head1 SYNOPSIS

    my $qiwi = Business::Qiwi->new(
        trm_id => 'your terminal id',
        serial => 'your confirmation code',
        password => 'your password',
    );
    my $balance = $qiwi->get_balance;

=head1 METHODS

=head2 Constructor

Constructor arguments:

=over 4

=item * $trm_id! -> Str

Account terminal id (login)

=item * $serial! -> Str

Account confirmation code

=item * $password! -> Str

Account password

=item * $cipher? -> Bool

Indicates if outgoing packets must be ciphered (note that, incoming packets are always plain XML)

Not implemented yet

=back

=head2 Operations

Methods which represents operations with your account

=over 4

=item * create_invoice(Num $amount, Str $to, Str $txn, Str $comment, Bool $sms_notify?, Bool $call_notify?, Int $confirm_time?) -> undef

Create outgoing QIWI invoice

Note: for operation result check out C<res_code>

=item * get_invoice_status(InvoicesList :$invoice) -> ArrayRef[HashRef]

Get outgoing invoice's status

=item * accept_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) -> undef

Confirm given invoice (works both for incoming and outgoing invoices)

=item * reject_invoice(Int :$qiwi_txn_id?, Int :$trm_txn_id?) -> undef

Disconfirm given invoice (works only for outgoing invoices)

=item * pay(Str :$to, Int :$service, Num :$amount, Str :$comment, Int :$id, Int :$receipt_id?) -> HashRef

Transfer money from your account

=item * get_payment_status(TxnsList :$txns) -> HashRef

Check your payment's status

=item * get_incoming_payments(Date :$since, Date :$to) -> ArrayRef[HashRef]

Get incoming payments

=item * get_phonebook() -> ArrayRef[HashRef]

Get entries from your QIWI phonebook

=item * add_to_phonebook(EntriesList :$entry) -> ArrayRef[Int]

Add entry to your QIWI phonebook (if you don't want to transfer money to given account just set C<amount> to 0)

=item * delete_from_phonebook(EntriesList :$id) -> ArrayRef[Int]

Delete entry from your QIWI phonebook

=item * register(Str :$password, Str :$phone) -> undef

Register C<$phone> as QIWI agent

=item * confirm_registration(Str :$password, Str :$phone, Str :$confirm) -> undef

Confirm C<$phone>'s registration

=item * get_report(Date :$since, Date :$to) -> ArrayRef[HashRef]

Get detailed report of payments made

=item * get_balance() -> Num

Get your QIWI balance

=back

=head2 Auxiliary methods

=over 4

=item * res_code -> Int
    
Numeric code of last operation result

=item * res_msg -> Str
    
Textual description of C<res_code>
    
Not implemented yet

=item * is_success -> Bool

Returns true if no errors occured during last operation

=item * is_fatal -> Bool

Indicate if occured error is fatal

Need to be called only if C<is_fatal> returned false

=back

=head1 TO DO

=over 4

=item * Implement ciphering

=item * Implement 'get banks list' request

=item * Implement result code description extraction

=back

=head1 REPOSITORY

L<http://github.com/ksurent/Business--Qiwi/tree/master>

=head1 AUTHOR

Алексей Суриков E<lt>ksuri@cpan.orgE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

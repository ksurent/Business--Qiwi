{
    package Business::Qiwi;
    our $VERSION = '0.01';
}

use MooseX::Declare;

class Business::Qiwi {
    use MooseX::Types::Moose qw(Num Int Str Bool HashRef);
    use Business::Qiwi::MooseSubtypes qw(Date EntriesList IdsList TxnsList BillsList);

    has trm_id   => ( is => 'rw', isa => Str, required => 1, );
    has password => ( is => 'rw', isa => Str, required => 1, );
    has serial   => ( is => 'rw', isa => Str, required => 1, );

    method create_bill(Num :$amount, Str :$to, Str :$txn, Str :$comment, Bool :$sms_notify?, Bool :$call_notify?, Int :$confirm_time?) {
        return $self->_create_object(
            'Bill',
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

    method get_bill_status(BillsList :$bill) {
        return $self->_create_object(
            'Bill::Status',
            {
                bill => $bill,
            },
        )
    }

    method accept_bill(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        return $self->_create_object(
            'Bill::Accept',
            {
                defined $qiwi_txn_id
                    ? (qiwi_txn_id => $qiwi_txn_id)
                    : (trm_txn_id  => $trm_txn_id)
            },
        )
    }

    before accept_bill(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
            if not defined $qiwi_txn_id and not defined $trm_txn_id
    }

    method reject_bill(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        return $self->_create_object(
            'Bill::Reject',
            {
                defined $qiwi_txn_id
                    ? (qiwi_txn_id => $qiwi_txn_id)
                    : (trm_txn_id  => $trm_txn_id)
            },
        )
    }

    before reject_bill(Int :$qiwi_txn_id?, Int :$trm_txn_id?) {
        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
            if not defined $qiwi_txn_id and not defined $trm_txn_id
    }

    method pay(Str :$to, Int :$service, Num :$amount, Str :$comment, Int :$id, Int :$receipt_id?) {
        return $self->_create_object(
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

    method get_payment_status(TxnsList :$txns) {
        return $self->_create_object(
            'Payment::Status',
            {
                txns => $txns,
            },
        )
    }

    method get_incoming_payments(Date :$since, Date :$to) {
        return $self->_create_object(
            'Payment::Incoming',
            {
                since => $since,
                to    => $to,
            },
        )
    }

    method get_phone_book() {
        return $self->_create_object('Phonebook')
    }

    method add_to_phonebook(EntriesList :$entry) {
        return $self->_create_object(
            'Phonebook::Add',
            {
                entry => $entry,
            },
        )
    }

    method delete_from_phonebook(IdsList :$id) {
        return $self->_create_object(
            'Phonebook::Delete',
            {
                id => $id,
            },
        )
    }

    method register(Str :$password, Str :$phone) {
       return $self->_create_object(
            'Register',
            {
                password => $password,
                phone    => $phone,
            },
        )
    }

    method confirm_registration(Str :$password, Str :$phone, Str :$confirm) {
        return $self->_create_object(
            'Register',
            {
                password => $password,
                phone    => $phone,
                confirm  => $confirm,
            },
        )
    }

#    method get_code_description(Int $code) {
#    }

    method get_report(Date :$since, Date :$to) {
        return $self->_create_object(
            'Report',
            {
                since => $since,
                to    => $to,
            },
        )
    }

    method get_balance() {
        return $self->_create_object('Balance', {})
    }

    method _create_object(Str $subclass!, HashRef $args = {}) {
        my $class = "Business::Qiwi::$subclass";

        my $is_loaded = eval "require $class; 1";
        Moose->throw_error("Subclass $class can not be loaded: $@") unless $is_loaded;

        my $instance = $class->new(
            trm_id => $self->trm_id,
            serial => $self->serial,
            password => $self->password,
            %$args,
        );
        return $instance->result
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi - Implementation of XML protocol for QIWI payments

=head1 SYNOPSIS

    my $qiwi = Business::Qiwi->new(
        trm_id => 'your terminal id',
        serial => 'your confirmation code',
        password => 'your password',
    );

=head1 DESCRIPTION

...

=head1 METHODS

=over 4

=item * create_bill(Num $amount, Str $to, Str $txn, Str $comment, Bool $sms_notify?, Bool $call_notify?, Int $confirm_time?)

    ...

    Arguments:

    Returns:

=item * get_bill_status()

    Get bill status.
    
    Arguments:
    
    Returns:

=item * accept_bill()

    Confirm you are gonna pay this bill.

    Arguments:

    Returns:

=item * reject_bill()

    Say you are not going to pay this.

    Arguments:

    Returns:

=item * pay()

    Pay for service.

    Arguments:

    Returns:

=item * get_payment_status()

    Check your payment.

    Arguments:

    Returns:

=item * get_incoming_payments()

    Get incoming payments.

    Arguments:

    Returns:

=item * get_phone_book()

    Get entries from phonebook.

    Arguments:

    Returns:

=item * add_to_phonebook()

    Add entry to phonebook.

    Arguments:

    Returns:

=item * delete_from_phonebook()

    Delete entry from phonebook.

    Arguments:

    Returns:

=item * register()

    Register somebody as QIWI agent.

    Arguments:

    Returns:

=item * confirm_registration()

    Confirm registration.

    Arguments:

    Register:

=item * get_code_description()

    Get text description of error code.

    Arguments:

    Returns:

=item * get_report()

    Get report for made payments.

    Arguments:

    Returns:

=item * get_balance()

    Get your QUWU balance.

    Arguments:

    Returns:

=back

=head1 TO DO

=over 4

=item * Implement ciphering

=item * Implement 'get banks list' request

=back

=head1 VERSION CONTROL

L<http://github.com/ksurent/Business--Qiwi/tree/master>

=head1 AUTHOR

Алексей Суриков E<lt>ksuri@cpan.orgE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

use MooseX::Declare;

class Business::Qiwi::Invoice::Accept extends Business::Qiwi::Request {
    use MooseX::Types::Moose qw(Int Str);

    has +request_type => ( default => 29, );

    has qiwi_txn_id => ( is => 'rw', isa => Int, default => undef, predicate => 'has_qiwi_txn_id', );
    has trm_txn_id  => ( is => 'rw', isa => Int, default => undef, predicate => 'has_trm_txn_id', );
    has action      => ( is => 'ro', isa => Str, default => 'accept', init_arg => undef, );

    augment create_request() {
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_extra_node('status', $self->action) );
        if($self->has_qiwi_txn_id) {
            $xml->appendChild( $self->_create_extra_node('bill-id', $self->qiwi_txn_id) )
        }
        else {
            $xml->appendChild( $self->_create_extra_node('trm-txn-id', $self->trm_txn_id) )
        }
        
        $xml
    }

    before create_request() {
        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
            if not $self->has_qiwi_txn_id and not $self->has_trm_txn_id
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Bill::Accept - Accept bills

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

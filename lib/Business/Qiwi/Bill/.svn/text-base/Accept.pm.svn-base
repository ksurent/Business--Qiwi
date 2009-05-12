use MooseX::Declare;

class Business::Qiwi::Bill::Accept extends Business::Qiwi::Request {
    has '+request_type' => ( default => 29, );

    has qiwi_txn_id => ( is => 'rw', isa => 'Int', lazy_build => 1, );
    has trm_txn_id  => ( is => 'rw', isa => 'Int', lazy_build => 1, );
    has action => ( is => 'ro', isa => 'Str', default => 'accept', init_arg => undef, );

    before create_request => sub {
        my $self = shift;
        
        Moose->throw_error('You must specify either qiwi_txn_id or trm_txn_id argument')
            if not $self->has_qiwi_txn_id and not $self->has_trm_txn_id
    };

    augment create_request => sub {
        my $self = shift;
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_extra_node('status', $self->action) );
        if($self->has_qiwi_txn_id) {
            $xml->appendChild( $self->_create_extra_node('bill-id', $self->qiwi_txn_id) )
        }
        else {
            $xml->appendChild( $self->_create_extra_node('trm-txn-id', $self->trm_txn_d) )
        }
        
        $xml
    }
};

no Moose;

1

__END__

=head1 NAME

Business::Qiwi::Bill::Accept - Accept bills

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

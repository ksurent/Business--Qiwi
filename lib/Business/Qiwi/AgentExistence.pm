use MooseX::Declare;

class Business::Qiwi::AgentExistence extends Business::Qiwi::Request {
    has '+request_type' => ( default => 32, );

    has phone => ( is => 'rw', isa => Str, required => 1, );

    augment create_request => sub {
        my $self = shift;
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_extra_node('phone', $self->phone) );
        
        $xml
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        return $self->_xml_response->findvalue('/response/exist') ? 1 : 0
    }
};

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::AgentExistence - Check if given phone number is registered in QIWI

=head1 SYNOPSIS

    printf "Agent ($phone) %s already registered",
        $qiwi->is_registered(phone => $phone)
            ? 'is'
            : 'is not'

=head1 DESCRIPTION

=head2 Constructor

=over 4

=item * phone => Str

Phone (account id) to check

=back

=head2 Returns

1 if agent exists and 0 otherwise

=cut

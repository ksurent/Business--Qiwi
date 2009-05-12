use MooseX::Declare;

class  Business::Qiwi::Balance extends Business::Qiwi::Request {
    has '+request_type' => ( default => 3, );

    augment create_request => sub {
        my $self = shift;
        
        return $self->_create_simple_node('request')
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        return $self->_xml_response->findvalue('/response/extra[@name="BALANCE"]')
    }
};

no Moose;

1

__END__

=head1 NAME

Business::Qiwi::Balance - Get available money amount

=head1 SYSNOPSIS

    printf "Balance: %.2f", $qiwi->get_balance

=head1 DESCRIPTION

=head2 Constructor

Takes no arguments

=head2 Returns

Stringified balance

=cut

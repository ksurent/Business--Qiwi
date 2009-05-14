use MooseX::Declare;

class Business::Qiwi::Bill::Status extends Business::Qiwi::Request {
    has '+request_type' => ( default => 33, );

    has bills => ( is => 'rw', isa => 'Business::Qiwi::MooseSubtypes::BillsList', coerce => 1, required => 1, );

    augment create_request => sub {
        my $self = shift;
        
        my $bills = $self->_create_simple_node('bills-list');
        $bills->appendChild( $self->_create_simple_node('bill', undef, {id => $_}) ) foreach @{ $self->bills };
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($bills);
        
        $xml
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        my @statuses;
        foreach($self->_xml_response->find('/response/bills-list/bill')->get_nodelist) {
            my $status = $_->getAttribute('status');
            
            if($status == 60)                     { $status = 1  }
            elsif($status == 50 or $status == 52) { $status = -1 }
            else                                  { $status = 0  }
            
            push @statuses, {id     => $_->getAttribute('id'),
                             status => $status,}        
        }
        
        \@statuses
    };
};

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Bill::Status - Get status of given bill

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

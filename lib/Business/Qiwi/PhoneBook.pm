use MooseX::Declare;

class Business::Qiwi::PhoneBook extends Business::Qiwi::Request {
    has '+request_type' => ( default => 36, );

    augment create_request() {
        my $self = shift;
        
        return $self->_create_simple_node('request')
    }

    augment parse_raw_response() {
        my $self = shift;
        
        return [
            map(
                {id    => $_->findvalue('./id'),
                 title => $_->findvalue('./title'),
                 phone => $_->findvalue('./account'),},
                $self->_xml_response->find('/response/book-list/book-item')->get_nodelist
            )
        ]
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::PhoneBook - Get you phonebook entries

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use MooseX::Declare;

class Business::Qiwi::PhoneBook::Delete extends Business::Qiwi::Request {
    use Business::Qiwi::MooseSubtypes qw(IdsList);

    has +request_type => ( default => 37, );

    has id => ( is => 'rw', isa => IdsList, coerce => 1, required => 1, );

    augment create_request() {
        my $ids = $self->_create_simple_node('item-list');
        $ids->appendChild($self->_create_simple_node('id', $_)) foreach @{ $self->id };
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($ids);
        
        $xml
    }

    augment parse_raw_response() {
        return [map($_->data, $self->_xml_response->find('/response/id')->get_nodelist)]
    }
}

no Moose;
no MooseX::Declare;

1


__END__

=head1 NAME

Business::Qiwi::PhoneBook::Delete - Delete entries from your phonenook

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

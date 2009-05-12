use MooseX::Declare;

class Business::Qiwi::PhoneBook::Add extends Business::Qiwi::Request {
    has '+request_type' => ( default => 38, );

    has entry => ( is => 'rw', isa => 'Business::Qiwi::MooseSubtypes::EntriesList', coerce => 1, required => 1, );

    augment create_request => sub {
        my $self = shift;
        
        my $items = $self->_create_simple_node('item-list');
        foreach( @{ $self->entry } ) {
            my $item = $self->_create_simple_node('item');
            $item->appendChild( $self->_create_simple_node('title', $_->{title}) );
            $item->appendChild( $self->_create_simple_node('prv', $_->{provider}) );
            $item->appendChild( $self->_create_simple_node('account', $_->{amount}) );
            $item->appendChild( $self->_create_simple_node('amount', $_->{amount}) );
            $item->appendChild( $self->_create_extra_node('comment', $_->{comment}) );
            $items->appendChild($item)
        }
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($items);
        
        $xml
    };

    augment parse_raw_response => sub {
        my $self = shift;
        
        return [map($_->data, $self->_xml_response->find('/response/id')->get_nodelist)]
    }
};

no Moose;

1

__END__

=head1 NAME

Business::Qiwi::PhoneBook::Add - Add entries to your phonebook

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

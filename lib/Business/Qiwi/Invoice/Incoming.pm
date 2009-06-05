use MooseX::Declare;

class Business::Qiwi::Invoice::Incoming extends Business::Qiwi::Request {
    use MooseX::Types::Moose qw(Int);
    use Business::Qiwi::MooseSubtypes qw(DateTime);

    has +request_type => ( default => 28, );

    has since => ( is => 'rw', isa => DateTime, required => 1, );
    has to    => ( is => 'rw', isa => DateTime, required => 1, );
    has direction => ( is => 'ro', isa => Int, default => 0, init_arg => undef, );

    augment create_request() {
        my $date_since = $self->_create_extra_node('from', $self->since);
        my $date_to    = $self->_create_extra_node('to', $self->to);
        my $direction  = $self->_create_extra_node('dir', $self->direction);

        my $xml = $self->_create_simple_node('request');
        $xml->appendChild($_) foreach $date_since, $date_to, $direction;

        $xml
    }

    augment parse_raw_response() {
        return [
            map +{
                id      => $_->findvalue('./id'),
                txn     => $_->findvalue('./term-ransaction'),
                date    => $_->findvalue('./bill-date'),
                amount  => $_->findvalue('./amount'),
                status  => $_->findvalue('./status'),
                from    => $_->findvalue('./from/trm-id'),
                comment => $_->findvalue('./comment'),
            }, $self->_xml_response->find('/response/account-list/account')->get_nodelist
        ]
    }


}

no Moose;
no MooseX::Declare;

1

__END__

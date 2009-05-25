use MooseX::Declare;

class Business::Qiwi::Registration extends Business::Qiwi::Request {
    require Digest::MD5;

    has '+request_type' => ( default => 20, );

    has password => (
        is => 'rw',
        isa => Str,
        required => 1,
        trigger => sub { shift->password( Digest::MD5::md5_hex(shift) ) },
    );
    has phone   => ( is => 'rw', isa => Str, required => 1, );
    has confirm => ( is => 'rw', isa => Str, lazy => 1, default => undef, );

    augment create_request() {
        my $self = shift;
        
        my $xml = $self->_create_simple_node('request');
        $xml->appendChild( $self->_create_simple_node('request-type', $self->request_type) );
        $xml->appendChild( $self->_create_extra_node('password-md5', $self->password) );
        $xml->appendChild( $self->_create_extra_node('phone', $self->phone) );
        if($self->has_confirm) {
            $xml->appendChild( $self->_create_extra_node('forAccept', 1) );
            $xml->appendChild( $self->_create_extra_node('acceptCode', $self->confirm) )
        }
        else {
            $xml->appendChild( $self->_create_extra_node('forAccept', 0) )
        }
        
        $xml
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Registration - Register given phone as QIWI agent

=head1 SYNOPSIS

    $qiwi->register(
        phone    => $phone,
        password => $password,
    );
    # $phone will receive SMS with confirmation code
    $qiwi->register(
        phone    => $phone,
        password => $password,
        confirm  => $confirm,
    );
    
=head1 DESCRIPTION

=head2 Constructor

=head2 Returns

=cut

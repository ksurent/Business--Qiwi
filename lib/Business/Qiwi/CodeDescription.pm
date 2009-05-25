use MooseX::Declare;

class Business::Qiwi::CodeDescription extends Business::Qiwi::Request {
    has '+request_type' => ( default => 6, );

    has cache_dir => ( is => 'ro', isa => Str, default => '/tmp/', );
    has cached    => ( is => 'rw', isa => 'DBM::Deep', lazy => 1, init_arg => 1, );

    augment create_request() {
        return $self->_create_simple_node('request')
    }

    augment parse_raw_response() {
        my $self = shift;
        
        return {
            map { $_->getAttribute('id') => $_->data }
            $self->_xml_response->find('/response/response-codes/response-code')->get_nodelist
        }
    }

    override result() {
    }

    after parse_raw_response() {
        my $self = shift;
        
        $self->_cache( $self->result )
    }
    
    method _cache(HashRef $result) {
        
    }
}

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::CodeDescription - Text descriptions of result/error codes

=head1 SYNOPSIS

    print $qiwi->get_code_description( $qiwi->code )

=head1 DESCRIPTION

=head2 Constructor

Takes no arguments

=head2 Returns

Stringified description

NOTE: descriptions will be cached to DB_File after first request

=cut

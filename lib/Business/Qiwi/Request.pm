use MooseX::Declare;

class Business::Qiwi::Request {
    use MooseX::Types::Moose qw(Int Str Bool HashRef Any);

    use XML::LibXML;
    require LWP::UserAgent;

    has trm_id   => ( is => 'rw', isa => Str, required => 1, );
    has password => ( is => 'rw', isa => Str, required => 1, );
    has serial   => ( is => 'rw', isa => Str, required => 1, );
    has cipher   => ( is => 'rw', isa => Bool, required => 0, );

    has url              => ( is => 'ro', isa => Str, default => 'https://www.mobw.ru/term2/xmlutf.jsp', init_arg => undef, );
    has protocol_version => ( is => 'ro', isa => Str, default => '4.0', init_arg => undef, );
    has request_type     => ( is => 'ro', isa => Int, init_arg => undef, ); 
    has code             => ( is => 'rw', isa => Int, init_arg => undef, );
#    has message          => ( is => 'rw', isa => Str, init_arg => undef, );
    has fatal            => ( is => 'rw', isa => Bool, init_arg => undef, );
    has success          => ( is => 'rw', isa => Bool, init_arg => undef, );
    has result           => ( is => 'rw', isa => Any, init_arg => undef, clearer => 'clear_result', );

    has _raw_request   => ( is => 'rw', isa => Str, init_arg => undef, );
    has _raw_response  => ( is => 'rw', isa => Str, init_arg => undef, );
    has _xml_response  => ( is => 'rw', isa => 'XML::LibXML::Document', init_arg => undef, clearer => '_clear_xml_response', );
#    has _ciphering_key => (
#        is      => 'ro',
#        isa     => Str,
#        lazy    => 1,
#        init_arg => undef,
#        default => sub {
#            my $self = shift;
#            
#            require Digest::MD5;
#
#            my @serial = pack 'c16', map ord, split '', Digest::MD5::md5($self->serial);
#            my @key    = pack 'c8', 0 x 8;
#            push @key,   pack 'c16', map ord, split '', Digest::MD5::md5($self->password);
#
#            $key[$_] ^= $serial[$_] for 0 .. $#serial;
#            
#            join '', @key
#        },
#    );

#    has _messages => (
#        is       => 'ro',
#        isa      => HashRef,
#        lazy     => 1,
#        default  => sub{{}},
#        init_arg => undef,
#    );

    method create_request() {
        my $req_node = inner();
        $req_node->appendChild( $self->_create_extra_node($_, $self->$_) ) foreach qw(password serial);
        $req_node->appendChild( $self->_create_simple_node('protocol-version', $self->protocol_version) );
        $req_node->appendChild( $self->_create_simple_node('terminal-id', $self->trm_id) );
        $req_node->appendChild( $self->_create_simple_node('request-type', $self->request_type) );
        
        my $xml = XML::LibXML::Document->new('1.0', 'utf-8');
        $xml->setDocumentElement($req_node);
        
        $self->_raw_request($xml->toString)
    }

#    after create_request() {
#        return unless $self->cipher;
#        
#        require Crypt::TripleDES;
#        
#        $self->_raw_request(
#            sprintf "Phone%s\n%s",
#                $self->trm_id,
#                unpack('H*', Crypt::TripleDES->new->encrypt3($self->_raw_request, $self->_ciphering_key))
#        )
#    }

    method send_request() {
        my $res = LWP::UserAgent->new->request(
            HTTP::Request->new(
                POST => $self->url,
                undef,
                $self->_raw_request,
            ),
        );
        unless($res->is_success) {
            $self->_clear_xml_response;
            $self->clear_result;
            return
        }
        
        $self->_raw_response($res->content)
    }

#    after send_request() {
#        return unless $self->cipher;
#        
#        require Crypt::TripleDES;
#        
#        $self->_raw_response( Crypt::TripleDES->new->decrypt3($self->_raw_response, $self->_ciphering_key) )
#    }

    method parse_raw_response() {
        $self->_xml_response( XML::LibXML->new->parse_string($self->_raw_response) );
        
        $self->code( int $self->_xml_response->findvalue('/response/result-code') );
#        $self->message( $self->_messages()->{$self->code} || '' );
        $self->success( $self->code ? 0 : 1 );
        $self->fatal( $self->_xml_response->findvalue('/response/result-code/@fatal') eq 'true' ? 1 : 0 );
        
        if($self->fatal) {
            $self->_clear_xml_response;
            $self->clear_result;
            $self->success(0);
            return
        }

        $self->result( inner() )
    }

    method _create_simple_node(Str $name, Str $value?, HashRef $attrs?) {
        my $node = XML::LibXML::Element->new($name);
        $node->appendText($value) if defined $value;
        
        if(defined $attrs) {
            $node->setAttribute($_, $attrs->{$_}) foreach keys %$attrs
        }
        
        $node
    }

    method _create_extra_node(Str $name, Str $value?, HashRef $attrs?) {
        my $node = XML::LibXML::Element->new('extra');
        $node->setAttribute('name', $name);
        $node->appendText($value) if defined $value;
        
        if(defined $attrs) {
            $node->setAttribute($_, $attrs->{$_}) foreach keys %$attrs
        }
        
        $node
    }
}

no Moose;
no MooseX::Declare;

1

__END__

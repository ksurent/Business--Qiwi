use MooseX::Declare;

use XML::LibXML;
require LWP::UserAgent;

class Business::Qiwi::Request {
    has trm_id   => ( is => 'rw', isa => 'Str', required => 1, );
    has password => ( is => 'rw', isa => 'Str', required => 1, );
    has serial   => ( is => 'rw', isa => 'Str', required => 1, );

#has cipher        => ( is => 'rw', isa => 'Bool', default => 0, );
#has ciphering_key => (
#    is      => 'ro',
#    isa     => 'Str',
#    lazy    => 1,
#    default => sub {
#        my $self = shift;
#        
#        eval "require Digest::MD5" or Moose->throw_error('Crypt::TripleDES must be installed to enable ciphering');
#        
#        my @key = ((0x00) x 8, split('', Digest::MD5::md5($self->password)));
#        my @serial = split('', Digest::MD5::md5($self->serial));
#        
#        $key[$_] ^= $serial[$_] for 0 .. $#serial;
#        
#        join '', @key
#    },
#    init_arg => undef,
#);

    has url              => ( is => 'ro', isa => 'Str',  lazy => 1, default => 'https://www.mobw.ru/term2/xmlutf.jsp', init_arg => undef, );
    has protocol_version => ( is => 'ro', isa => 'Str',  lazy => 1, default => '4.0', init_arg => undef, );
    has request_type     => ( is => 'ro', isa => 'Int',  lazy => 1, default => undef, init_arg => undef, );
    has request          => ( is => 'rw', isa => 'Str',  lazy => 1, default => undef, init_arg => undef, );
    has code             => ( is => 'rw', isa => 'Int',  lazy => 1, default => undef, init_arg => undef, );
    has fatal            => ( is => 'rw', isa => 'Bool', lazy => 1, default => undef, init_arg => undef, );
    has result           => ( is => 'rw', isa => 'Str',  lazy_build => 1, default => undef, init_arg => undef, );

    has _raw_response => ( is => 'rw', isa => 'Str', lazy_build => 1, init_arg => undef, );
    has _xml_response => ( is => 'rw', isa => 'XML::LibXML::Document', lazy_build => 1, init_arg => undef, );

    method create_request() {
        my $req_node = inner();
        $req_node->appendChild( $self->_create_extra_node($_, $self->$_) ) foreach qw(password serial);
        $req_node->appendChild( $self->_create_simple_node('protocol-version', $self->protocol_version) );
        $req_node->appendChild( $self->_create_simple_node('terminal-id', $self->trm_id) );
        $req_node->appendChild( $self->_create_simple_node('request-type', $self->request_type) );
        
        my $xml = XML::LibXML::Document->new('1.0', 'utf-8');
        $xml->setDocumentElement($req_node);
        
        $self->request($xml->toString)
    }

#after create_request => sub {
#    my $self = shift;
#    
#    return unless $self->cipher;
#    
#    require Crypt::TripleDES;
#    
#    my $ciphered_text = sprintf "Phone%s\n%s",
#                            $self->trm_id,
#                            unpack('H*', Crypt::TripleDES->new->encrypt3($self->request, $self->ciphering_key));
#    
#    $self->request($ciphered_text)
#};

    method send_request() {
        my $ua = LWP::UserAgent->new(agent => 'Business::Qiwi');
        my $res = $ua->request(
            HTTP::Request->new(
                POST => $self->url,
                undef,
                $self->request,
            ),
        );
        unless($res->is_success) {
            $self->clear_xml_response;
            $self->clear_result;
            return
        }
        
        $self->_raw_response($res->content);
        $self->parse_raw_response
    }

#after send_request => sub {
#    my $self = shift;
#    
#    return unless $self->cipher;
#    
#    $self->_raw_response( Crypt::TripleDES->new->decrypt3($self->_raw_response, $self->ciphering_key) )
#};

    method parse_raw_response() {
        $self->_xml_response( XML::LibXML->new->parse_string($self->_raw_response) );
        
        $self->code( int $self->_xml_response->findvalue('/response/result-code') );
        $self->fatal( $self->_xml_response->findvalue('/response/result-code/@fatal') eq 'true' ? 1 : 0 );
        
        if($self->code or $self->fatal) {
            $self->clear_xml_response;
            $self->clear_result;
            return
        }
        
        $self->result( inner() )
    }

    method _create_simple_node(Str :$name, Str :$value?, HashRef :$attrs?) {
        my $node = XML::LibXML::Element->new($name);
        $node->appendText($value) if defined $value;
        
        if(defined $attrs) {
            $node->setAttribute($_, $attrs->{$_}) foreach keys %$attrs
        }
        
        $node
    }

    method _create_extra_node(Str :$name, Str :$value?, HashRef :$attrs?) {
        my $node = XML::LibXML::Element->new('extra');
        $node->setAttribute('name', $name);
        $node->appendText($value) if defined $value;
        
        if(defined $attrs) {
            $node->setAttribute($_, $attrs->{$_}) foreach keys %$attrs
        }
        
        $node
    }
};

no Moose;

1

__END__

=head1 NAME

Business::Qiwi::Request - Base class for all request objects

=cut

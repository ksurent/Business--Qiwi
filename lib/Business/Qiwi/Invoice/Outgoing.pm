use MooseX::Declare;

class Business::Qiwi::Invoice::Outgoing extends Business::Qiwi::Invoice::Incoming {
    has +direction => ( default => 1, )
}

no Moose;
no MooseX::Declare;

1

__END__

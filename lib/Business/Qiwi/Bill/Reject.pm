use MooseX::Declare;

class Business::Qiwi::Bill::Reject extends Business::Qiwi::Bill::Accept {
    has '+action' => ( default => 'reject', )
};

no Moose;
no MooseX::Declare;

1

__END__

=head1 NAME

Business::Qiwi::Bill::Reject - Reject bills

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

package Business::Qiwi::MooseSubtypes;

use MooseX::Types::Moose qw(Int Str ArrayRef HashRef);
use MooseX::Types -declare => [qw(Date PBEntry EntriesList IdsList TxnsList BillsList)];

subtype Date,
    as Str,
    where { /^(\d{1,2})\.(\d{1,2})\.\d{4}$/ && $1 >= 0 && $1 <= 31 && $2 >= 1 && $2 <= 12 },
    message { 'Date must be provided in DD.MM.YYYY format' };

subtype PBEntry,
    as HashRef,
    where { defined $_->{id} and defined $_->{title} and defined $_->{account} },
    message { 'PBEntry must consist of three keys: id, title, account' };

subtype EntriesList, as ArrayRef[PBEntry];
subtype IdsList,     as ArrayRef[Int];
subtype TxnsList,    as ArrayRef[Int];
subtype BillsList,   as ArrayRef[Int];

coerce EntriesList, from HashRef, via { [$_] };
coerce IdsList,     from Int,     via { [$_] };
coerce TxnsList,    from Int,     via { [$_] };
coerce BillsList,   from Int,     via { [$_] };

1

__END__

=head1 NAME

Business::Qiwi::MooseSubtypes - Custom Moose-based data types

=head1 DESCRIPTION

Moose best practices recommends to define all subtypes in one class and then load it if needed

=head1 SEE ALSO

L<Moose::Manual::BestPractices>

=cut

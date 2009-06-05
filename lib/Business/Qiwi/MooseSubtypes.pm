package Business::Qiwi::MooseSubtypes;

use MooseX::Types::Moose qw(Int Num Str ArrayRef HashRef);
use MooseX::Types -declare => [qw(Date DateTime PBEntry EntriesList IdsList TxnsList InvoicesList)];

subtype Date,
    as Str,
    where { /^(\d{2})\.(\d{2})\.\d{4}$/ and is_Day($1) and is_Month($2)  },
    message { 'Date must be provided in DD.MM.YYYY format' };

subtype DateTime,
    as Str,
    where { /^(\d{2})\.(\d{2})\.\d{4} (\d{2}):(\d{2}):(\d{2})$/ and is_Day($1) and is_Month($2) and is_Time($3) and is_Time($4) and is_Time($5) },
    message { 'Date and time must be provided in DD.MM.YYYY HH:MM:SS format' };

subtype PBEntry,
    as HashRef,
    where { is_Str $_->{title} and is_Str $_->{account} and is_Int($_->{provider} and is_Num($_->{amount})) },
    message { 'PBEntry must consist of four fields: id, title, account, amount' };

subtype EntriesList,  as ArrayRef[PBEntry];
subtype IdsList,      as ArrayRef[Int];
subtype TxnsList,     as ArrayRef[Int];
subtype InvoicesList, as ArrayRef[Int];

coerce EntriesList,  from PBEntry, via { [$_] };
coerce IdsList,      from Int,     via { [$_] };
coerce TxnsList,     from Int,     via { [$_] };
coerce InvoicesList, from Int,     via { [$_] };

sub is_Month($) {
    my $m = shift;

    ($m >= 1) & ($m <= 12)
}

sub is_Day($) {
    my $d = shift;

    ($d >= 1) & ($d <= 31)
}

sub is_Time($) {
    my $t = shift;

    ($t >= 0) & ($t <= 60)
}

1

__END__

=head1 NAME

Business::Qiwi::MooseSubtypes - Custom Moose-based data types

=head1 DESCRIPTION

=head 2 Subtypes

=over 4

=item EntriesList => PBEntry|ArrayRef[PBEntry]

=item InvoicesList => Int|ArrayRef[Int]

=item TxnsList => Int|ArrayRef[Int]

=item IdsList => Int|ArrayRef[Int]

=item PBEntry => HashRef

Represents phonebook entry

Mandatory keys:

=over 8

=item id => Int

Unique id number for the entry

=item account => Str

Contact phone number

=item title => Str

Display name of the entry

=back

=item Date => Str

Date in DD.MM.YYYY format

=back

=head2 Coercion

All the subtypes will be coerced from a single SCALAR to ARRAYREF with this SCALAR

=cut

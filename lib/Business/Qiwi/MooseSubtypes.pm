package Business::Qiwi::MooseSubtypes;

use MooseX::Types -declare => [qw(Date EntriesList IdsList TxnsList BillsList)];
use MooseX::Types::Moose qw(Int Str ArrayRef HashRef);

subtype Date => as Str => where { /^\d{2}\.\d{2}\.\d{4}$/ } => message { 'Date must be provided in DD.MM.YYYY format' };

subtype EntriesList => as ArrayRef[HashRef];
coerce EntriesList => from HashRef => via { [$_] };

subtype IdsList => as ArrayRef[Int];
coerce IdsList => from Int => via { [$_] };

subtype TxnsList => as ArrayRef[Int];
coerce TxnsList => from Int => via { [$_] };

subtype BillsList => as ArrayRef[Int];
coerce BillsList => from Int => via { [$_] };

1

__END__

=head1 NAME

Business::Qiwi::MooseSubtypes - Custom Moose-based data types

=head1 DESCRIPTION

Moose best practices recommends to define all subtypes in one class and then load it if needed

=head1 SEE ALSO

L<Moose::Manual::BestPractices>

=cut
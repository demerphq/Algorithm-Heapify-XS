package Algorithm::Heapify::XS;

use 5.018004;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# This allows declaration:
#   use Algorithm::Heapify::XS ':all';

our %EXPORT_TAGS = (
    'all' => [
        'heap_parent_idx',
        'heap_left_child_idx',
        'heap_right_child_idx',
        map { ("min_$_", "max_$_","minstr_$_","maxstr_$_") }
            (
                'heapify',
                'heap_shift',
                'heap_push',
                'heap_adjust_top',
                'heap_adjust_item',
            )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

foreach my $prefix (qw(max min maxstr minstr)) {
    $EXPORT_TAGS{$prefix}= [ grep { /^${prefix}_/ } @EXPORT_OK ];
}
$EXPORT_TAGS{idx}= [ grep { /_idx\z/ } @EXPORT_OK ];

our @EXPORT = qw();

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Algorithm::Heapify::XS', $VERSION);

sub heap_parent_idx($) {
    die "index must be non-negative" if $_[0] < 0;
    return $_[0] ? int(($_[0] - 1) / 2) : undef;
}

sub heap_left_child_idx($) {
    die "index must be non-negative" if $_[0] < 0;
    return 2*$_[0]+1;
}

sub heap_right_child_idx($) {
    die "index must be non-negative" if $_[0] < 0;
    return 2*$_[0]+2;
}


1;
__END__

=head1 NAME

Algorithm::Heapify::XS - Perl extension for supplying simple heap primitives for arrays.

=head1 SYNOPSIS

  use Algorithm::Heapify::XS qw(max_heapify max_heap_shift);
  my @array= (1..10);
  max_heapify(@array);
  while (defined(my $top= max_heap_shift(@array))) {
    print $top;
  }


=head1 DESCRIPTION

A heap is an array based data structure where the array is treated as a balanced tree
of items where each item obeys a given inequality constraint with its its parent and children,
but not with its siblings.

This data structure has a number of nice properties:

a) the tree does not require "child" pointers, but instead infers parent/child
relationships from their position in the array. The parent of a node i is defined to
reside in position int((i-1)/2), and the left and right children of a node i reside in
position (i*2+1) and (i*2+2) respectively.

b) "heapifying" an array is O(N) as compared to N * log2(N) for a typical sort.

c) Accessing the top item is O(1), and removing it from the array is O(log(N)).

d) Inserting a new item into the heap is O(log(N))

This means that for applications that need find only the top K of an array can do it faster
than sorting the array, and there is no need for wrapper objects to represent the tree.

=head2 INTERFACE

All operations are in-place on the array passed as an argument, and all require that the
appropriate "heapify" (either max_heapify or min_heapify) operation has been called on the
array first. Typically they return the "top" of the heap after the operation has been performed,
with the exception of the "shift" operation which returns the "top" of the heap before
removing it.

Currently there is no support for supplying a sort comparator akin to sort(), instead
you should define an overloaded <=> operator if you wish to change the sort order.

The ordering is expected to be *numeric*, if you wish to sort words you should use
objects with overloading.

=head2 EXPORT

None by default. All exports must be requested, or you can use ":all" to import then all.

=head2 SUBS

=over 4

=item $max= max_heapify(@array)

=item $min= min_heapify(@array)

=item $max= maxstr_heapify(@array)

=item $min= minstr_heapify(@array)

These subs "heapify" the array and return its "top" (min/max) value. Prior use of the
appropriate one of these subs is required to use all the other subs offered by this package.

=item $max= max_heap_shift(@array)

=item $min= min_heap_shift(@array)

=item $max= maxstr_heap_shift(@array)

=item $min= minstr_heap_shift(@array)

Return and remove the "top" (min/max) value from a heapified array while maintain the arrays
heap-order.

=item $max= max_heap_push(@array)

=item $min= min_heap_push(@array)

=item $max= maxstr_heap_push(@array)

=item $min= minstr_heap_push(@array)

Insert an item into a heapified array while maintaining the arrays heap-order, and return the
resulting "top" (min/max) value.

=item $max= max_heap_adjust_top(@array)

=item $max= min_heap_adjust_top(@array)

=item $max= maxstr_heap_adjust_top(@array)

=item $max= minstr_heap_adjust_top(@array)

If the weight of the top item in a heapified array ($array[0]) has changed, this function will
adjust its position in the tree, and return the resulting new "top" (min/max) value.

=item $max= max_heap_adjust_item(@array,$idx)

=item $max= min_heap_adjust_item(@array,$idx)

=item $max= maxstr_heap_adjust_item(@array,$idx)

=item $max= minstr_heap_adjust_item(@array,$idx)

If the weight of a specific item in a heapified array has changed, this function will
adjust its position in the tree, and return the resulting new "top" (min/max) value.
If $idx is outside the array does nothing.

=head1 SEE ALSO

CPAN - There are other heap packages with different interfaces if you dont like this one.

=head1 AUTHOR

Yves Orton, E<lt>yorton@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by Yves Orton

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

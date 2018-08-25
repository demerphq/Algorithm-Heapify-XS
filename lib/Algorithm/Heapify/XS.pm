package Algorithm::Heapify::XS;

use 5.018004;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Algorithm::Heapify::XS ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    heapify
    heap_shift
    heap_adjust_top
    heap_adjust_item
    heap_parent_idx
    heap_left_child_idx
    heap_right_child_idx
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Algorithm::Heapify::XS', $VERSION);

# Preloaded methods go here.

sub heap_parent_idx($) {
    return $_[0] ? int(($_[0] - 1) / 2) : undef;
}

sub heap_left_child_idx($) {
    return 2*$_[0]+1;
}

sub heap_right_child_idx($) {
    return 2*$_[0]+2;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Algorithm::Heapify::XS - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Algorithm::Heapify::XS;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Algorithm::Heapify::XS, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Yves Orton, E<lt>yorton@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by Yves Orton

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Algorithm-Heapify-XS.t'

#########################
use strict;
use warnings;

# change 'tests => 1' to 'tests => last_test_to_print';
use Test::More tests => 1;
use Devel::Peek;

package Oload;
use strict;
use warnings;
use overload
    '<=>' => sub {
        my ($l,$r,$swap)= @_;
        ($l,$r)= ($r,$l) if $swap;
        ref($_) and $_= $$_
            for $l, $r;
        my $ret= $l cmp $r;
        warn "Oload <=> $l,$r => $ret\n";
        return $ret;
    },
    fallback => 1,
;

package OloadAry;
use strict;
use warnings;
use overload
    '<=>' => sub {
        my ($l,$r,$swap)= @_;
        ($l,$r)= ($r,$l) if $swap;
        ref($_) and $_= $_->[0]
            for $l, $r;
        warn "OloadAry <=> $l,$r\n";
        my $ret= $l cmp $r;
        return $ret;
    },
    fallback => 1,
;
package main;
BEGIN { use_ok('Algorithm::Heapify::XS') };
use Algorithm::Heapify::XS ':all';
#my @n= (1..10);
#heapify(@n);

my @arrays= map {
    [ map { my $x= chr(ord("A")+int rand 26); bless \$x, "Oload" } (1..100) ]
} 1 .. 10;
use Data::Dumper;
#print Dumper(\@arrays);

#heapify(@$_) for @arrays;
heapify(@{$arrays[0]});



#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


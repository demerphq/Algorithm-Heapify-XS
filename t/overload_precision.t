use strict;
use warnings;

use Config;
use Test::More;

use Algorithm::Heapify::XS qw(
    max_heapify
    max_heap_shift
    min_heapify
    min_heap_shift
);

{
    package Local::BigNumOnly;

    use overload
        '0+' => sub { ${$_[0]} },
        '""' => sub { ${$_[0]} },
        fallback => 1;

    sub new {
        my ($class, $value) = @_;
        return bless \$value, $class;
    }
}

my $nv_preserves_64bit_uv =
    ($Config{nvsize} * 8) >= 64
    && (~0 <= 9_007_199_254_740_992);

plan skip_all => 'needs UV values larger than NV can exactly represent'
    if $nv_preserves_64bit_uv;

my $big = ~0;
my @values = ($big - 1, $big, $big - 2, $big - 3, $big - 4);

{
    my @heap = map Local::BigNumOnly->new($_), @values;
    my @got;

    max_heapify(@heap);
    push @got, 0 + max_heap_shift(@heap) while @heap;

    is_deeply(
        \@got,
        [ sort { $b <=> $a } @values ],
        'max heap keeps overloaded large UVs in numeric order',
    );
}

{
    my @heap = map Local::BigNumOnly->new($_), @values;
    my @got;

    min_heapify(@heap);
    push @got, 0 + min_heap_shift(@heap) while @heap;

    is_deeply(
        \@got,
        [ sort { $a <=> $b } @values ],
        'min heap keeps overloaded large UVs in numeric order',
    );
}

done_testing;

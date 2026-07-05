#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(sum min);

my @w = map { 0 + $_ } <>;
my $total = sum(@w);

sub qe {
    my ($arr) = @_;
    my $p = 1;
    $p *= $_ for @$arr;
    return $p;
}

sub solve {
    my ($groups) = @_;

    my $target = $total / $groups;

    # try smallest group size first (critical optimization)
    for my $size (1 .. scalar(@w)) {

        my @best;

        my @idx = (0 .. $#w);

        # bitmask combinations via recursion (fast + minimal overhead)
        my @stack = ( [ [], 0, 0 ] );  # picked, sum, start

        while (@stack) {
            my ($picked, $sum, $start) = @{ pop @stack };

            if (@$picked == $size) {
                next if $sum != $target;

                push @best, qe($picked);
                next;
            }

            for my $i ($start .. $#w) {
                my $new_sum = $sum + $w[$i];

                next if $new_sum > $target;

                push @stack, [
                    [ @$picked, $w[$i] ],
                    $new_sum,
                    $i + 1
                ];
            }
        }

        if (@best) {
            return min(@best);
        }
    }

    return -1;
}

print "2015 day24: pl_ans_1: " . solve(3) . "\n";
print "2015 day24: pl_ans_2: " . solve(4) . "\n";

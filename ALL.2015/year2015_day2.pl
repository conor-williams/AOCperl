#!/usr/bin/env perl

use strict;
use warnings;

open my $fh, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!";
my @lines = <$fh>;
close $fh;

chomp @lines;

my $total1 = 0;
my $total2 = 0;

foreach my $line (@lines) {

    my ($x, $y, $z) = map { int($_) } split /x/, $line;

    my $a1 = $x * $y;
    my $a2 = $y * $z;
    my $a3 = $x * $z;

    # ---------------------------------
    # part 1
    # ---------------------------------
    my $surface = (2 * $a1) + (2 * $a2) + (2 * $a3);

    my $extra = $a1;
    $extra = $a2 if $a2 < $extra;
    $extra = $a3 if $a3 < $extra;

    $total1 += $surface + $extra;

    # ---------------------------------
    # part 2
    # ---------------------------------
    my @sides = sort { $a <=> $b } ($x, $y, $z);

    my $ribbon = (2 * $sides[0]) + (2 * $sides[1]);

    my $bow = $x * $y * $z;

    $total2 += $ribbon + $bow;
}

print "2015 day2: pl_ans_1: $total1\n";
print "2015 day2: pl_ans_2: $total2\n";

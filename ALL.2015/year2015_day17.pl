#!/usr/bin/env perl

use strict;
use warnings;

my @dimensions;

open my $fh, '<', $ARGV[0] or die $!;
while (<$fh>) {
    chomp;
    push @dimensions, 0 + $_;
}
close $fh;

my %dist;

my $n = scalar @dimensions;

for my $mask (1 .. (1 << $n) - 1) {

    my @p;

    for my $i (0 .. $n - 1) {
        push @p, $dimensions[$i] if ($mask & (1 << $i));
    }

    my $sum = 0;
    $sum += $_ for @p;

    next unless $sum == 150;

    $dist{scalar @p}++;
}

my $total = 0;
$total += $_ for values %dist;

my $min_key = (sort { $a <=> $b } keys %dist)[0];

print "2015 day17: pl_ans_1: $total\n";
print "2015 day17: pl_ans_2: $dist{$min_key}\n";

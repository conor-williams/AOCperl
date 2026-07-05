#!/usr/bin/env perl
use strict;
use warnings;

use List::Util qw(max);

my $file = $ARGV[0] or die "Usage: perl day15.pl input.txt\n";

my @cookies;

# ----------------------------
# Parse input safely
# ----------------------------
open my $fh, "<", $file or die "Cannot open $file: $!";

while (my $line = <$fh>) {

    # Extract all integers (including negatives if present)
    my @g = ($line =~ /(-?\d+)/g);

    # Expected: capacity, durability, flavor, texture, calories
    push @cookies, \@g;
}

close $fh;

# ----------------------------
# Brute force distribution
# ----------------------------
my $best_total = 0;
my $best_cal   = 0;

for my $i (0..100) {
for my $j (0..100-$i) {
for my $k (0..100-$i-$j) {

    my $l = 100 - $i - $j - $k;

    my @score = (0,0,0,0,0);

    for my $p (0..4) {
        $score[$p] =
            $i * $cookies[0][$p] +
            $j * $cookies[1][$p] +
            $k * $cookies[2][$p] +
            $l * $cookies[3][$p];
    }

    # skip invalid cookies
    next if $score[0] <= 0
         || $score[1] <= 0
         || $score[2] <= 0
         || $score[3] <= 0;

    my $total = $score[0] * $score[1] * $score[2] * $score[3];

    $best_total = $total if $total > $best_total;

    if ($score[4] == 500) {
        $best_cal = $total if $total > $best_cal;
    }
}}

}

# ----------------------------
# Output
# ----------------------------
print "2015 day15: pl_ans_1: $best_total\n";
print "2015 day15: pl_ans_2: $best_cal\n";

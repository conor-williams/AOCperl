#!/usr/bin/perl
use strict;
use warnings;

my $path = $ARGV[0];

open my $fh, "<", $path or die "$path: $!";

my @nums;

while (<$fh>) {
    chomp;
    next unless $_ =~ /\S/;
    push @nums, int($_);
}

close $fh;


# ----------------
# Part 1
# ----------------

my $p1 = 0;

for my $i (1 .. $#nums) {
    if ($nums[$i] > $nums[$i-1]) {
        $p1++;
    }
}


# ----------------
# Part 2
# sliding window 3
# ----------------

my $p2 = 0;

for my $i (3 .. $#nums) {
    if ($nums[$i] > $nums[$i-3]) {
        $p2++;
    }
}


print "2021 day1: pl_ans_1: $p1\n";
print "2021 day1: pl_ans_2: $p2\n";

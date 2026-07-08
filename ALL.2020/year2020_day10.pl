#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @nums;

while (<$fh>) {
    push @nums, map { int($_) } split;
}

close($fh);

@nums = sort { $a <=> $b } @nums;

unshift @nums, 0;
push @nums, $nums[-1] + 3;

# ---------------- Part 1 ----------------

my ($diff1, $diff3) = (0, 0);

for (my $i = 0; $i < @nums - 1; $i++) {

    my $d = $nums[$i + 1] - $nums[$i];

    $diff1++ if $d == 1;
    $diff3++ if $d == 3;
}

my $p1 = $diff1 * $diff3;

# ---------------- Part 2 ----------------

my %ways;
$ways{0} = 1;

for (my $i = 1; $i < @nums; $i++) {

    my $x = $nums[$i];

    $ways{$x} =
          ($ways{$x-1} || 0)
        + ($ways{$x-2} || 0)
        + ($ways{$x-3} || 0);
}

my $p2 = $ways{$nums[-1]};

print "2020 day10: pl_ans_1: $p1\n";
print "2020 day10: pl_ans_2: $p2\n";

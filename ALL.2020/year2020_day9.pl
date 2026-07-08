#!/usr/bin/perl
use strict;
use warnings;

sub valid {
    my ($nums, $target) = @_;

    my %seen;

    foreach my $n (@$nums) {

        return 1 if exists $seen{$target - $n};

        $seen{$n} = 1;
    }

    return 0;
}

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @nums;

while (<$fh>) {
    push @nums, map { int($_) } split;
}

close($fh);

# ---------------- Part 1 ----------------

my $preamble = 25;
my $invalid;

for (my $i = $preamble; $i < @nums; $i++) {

    my @window = @nums[$i - $preamble .. $i - 1];

    unless (valid(\@window, $nums[$i])) {
        $invalid = $nums[$i];
        last;
    }
}

my $p1 = $invalid;

# ---------------- Part 2 ----------------

my $left = 0;
my $sum = 0;
my $p2;

for (my $right = 0; $right < @nums; $right++) {

    $sum += $nums[$right];

    while ($sum > $invalid) {
        $sum -= $nums[$left];
        $left++;
    }

    if ($sum == $invalid && $right - $left >= 1) {

        my @window = @nums[$left .. $right];

        my $min = $window[0];
        my $max = $window[0];

        foreach my $v (@window) {
            $min = $v if $v < $min;
            $max = $v if $v > $max;
        }

        $p2 = $min + $max;
        last;
    }
}

print "2020 day9: pl_ans_1: $p1\n";
print "2020 day9: pl_ans_2: $p2\n";

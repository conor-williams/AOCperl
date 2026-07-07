#!/usr/bin/perl

use strict;
use warnings;

open(my $fh, "<", $ARGV[0]) or die $!;
my @lines = <$fh>;
close($fh);

chomp @lines;

# -----------------------------------------
# part 1
# -----------------------------------------

my $total1 = 0;

for my $line (@lines) {

    my @nums = split(/\s+/, $line);

    my $max = $nums[0];
    my $min = $nums[0];

    for my $n (@nums) {
        $max = $n if $n > $max;
        $min = $n if $n < $min;
    }

    $total1 += $max - $min;
}

# -----------------------------------------
# part 2
# -----------------------------------------

my $total2 = 0;

for my $line (@lines) {

    my @nums = split(/\s+/, $line);

    my $found = 0;

    for (my $i = 0; $i < @nums; $i++) {

        for (my $j = 0; $j < @nums; $j++) {

            next if $i == $j;

            my $a = $nums[$i];
            my $b = $nums[$j];

            if ($a % $b == 0) {
                $total2 += int($a / $b);
                $found = 1;
                last;
            }
        }

        last if $found == 1;
    }
}

print "2017 day2: pl_ans_1: $total1\n";
print "2017 day2: pl_ans_2: $total2\n";

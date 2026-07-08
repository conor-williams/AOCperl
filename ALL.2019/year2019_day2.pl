#!/usr/bin/perl

use strict;
use warnings;

sub run_program {

    my ($nums) = @_;

    my $ip = 0;

    while (1) {

        my $op = $nums->[$ip];

        if ($op == 99) {
            last;
        }

        my $a = $nums->[$ip + 1];
        my $b = $nums->[$ip + 2];
        my $c = $nums->[$ip + 3];

        if ($op == 1) {

            $nums->[$c] = $nums->[$a] + $nums->[$b];

        }
        elsif ($op == 2) {

            $nums->[$c] = $nums->[$a] * $nums->[$b];

        }

        $ip += 4;
    }

    return $nums->[0];
}


my $path = $ARGV[0];

open my $fh, '<', $path or die $!;

my $line = <$fh>;

close $fh;

chomp $line;

my @original = map { int($_) } split /,/, $line;

# -----------------------------------------
# part 1
# -----------------------------------------

my @nums = @original;

$nums[1] = 12;
$nums[2] = 2;

my $part1 = run_program(\@nums);

# -----------------------------------------
# part 2
# -----------------------------------------

my $target = 19690720;

my $part2 = 0;

for my $noun (0 .. 99) {

    for my $verb (0 .. 99) {

        @nums = @original;

        $nums[1] = $noun;
        $nums[2] = $verb;

        my $ans = run_program(\@nums);

        if ($ans == $target) {

            $part2 = 100 * $noun + $verb;
        }
    }
}

print "2019 day2: pl_ans_1: $part1\n";
print "2019 day2: pl_ans_2: $part2\n";

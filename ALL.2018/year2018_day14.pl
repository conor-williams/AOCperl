#!/usr/bin/perl

use strict;
use warnings;

# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my $target = <$fh>;

close($fh);

chomp $target;

my @target_list = split //, $target;
my $target_num  = int($target);

# -------------------------------------------------
# Initial state
# -------------------------------------------------

my @state = (3, 7);

my $pos1 = 0;
my $pos2 = 1;

my $part1_done = 0;

# -------------------------------------------------
# Handle initial state for part 2
# -------------------------------------------------

if (@target_list <= @state)
{
    my $match = 1;

    for my $i (0 .. $#target_list)
    {
        if ($state[$i] != $target_list[$i])
        {
            $match = 0;
            last;
        }
    }

    if ($match)
    {
        print "2018 day14: pl_ans_2: 0\n";
        exit;
    }
}

# -------------------------------------------------
# Main loop
# -------------------------------------------------

while (1)
{
    my $sum = $state[$pos1] + $state[$pos2];

    foreach my $d (split //, $sum)
    {
        push @state, $d;

        # -----------------------------------------
        # Part 1
        # -----------------------------------------

        if (!$part1_done &&
            @state >= $target_num + 10)
        {
            my $answer = "";

            for my $i ($target_num .. $target_num + 9)
            {
                $answer .= $state[$i];
            }

            print "2018 day14: pl_ans_1: $answer\n";

            $part1_done = 1;
        }

        # -----------------------------------------
        # Part 2
        # -----------------------------------------

        if (@state >= @target_list)
        {
            my $match = 1;
            my $start = @state - @target_list;

            for my $i (0 .. $#target_list)
            {
                if ($state[$start + $i] != $target_list[$i])
                {
                    $match = 0;
                    last;
                }
            }

            if ($match)
            {
                print "2018 day14: pl_ans_2: $start\n";
                exit;
            }
        }
    }

    $pos1 = ($pos1 + 1 + $state[$pos1]) % @state;
    $pos2 = ($pos2 + 1 + $state[$pos2]) % @state;
}

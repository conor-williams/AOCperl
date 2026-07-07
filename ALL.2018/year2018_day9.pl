#!/usr/bin/perl

use strict;
use warnings;

# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my $line = <$fh>;

close($fh);

my ($players, $last_marble) = ($line =~ /(\d+).*?(\d+)/);


# -------------------------------------------------
# Play marble game
# -------------------------------------------------

sub play
{
    my ($players, $last) = @_;

    my @scores = (0) x $players;


    # Circular linked list
    my @next;
    my @prev;


    $next[0] = 0;
    $prev[0] = 0;


    my $current = 0;


    for my $marble (1 .. $last)
    {
        my $player = ($marble - 1) % $players;


        if ($marble % 23 != 0)
        {
            # Insert new marble between
            # current+1 and current+2

            my $a = $next[$current];
            my $b = $next[$a];


            $next[$a] = $marble;
            $prev[$marble] = $a;

            $next[$marble] = $b;
            $prev[$b] = $marble;


            $current = $marble;
        }
        else
        {
            $scores[$player] += $marble;


            # Move 7 marbles counter-clockwise

            for (1 .. 7)
            {
                $current = $prev[$current];
            }


            $scores[$player] += $current;


            # Remove current marble

            my $before = $prev[$current];
            my $after  = $next[$current];


            $next[$before] = $after;
            $prev[$after]  = $before;


            $current = $after;
        }
    }


    my $high = 0;

    for my $score (@scores)
    {
        $high = $score if $score > $high;
    }


    return $high;
}


# -------------------------------------------------
# Part 1
# -------------------------------------------------

my $p1 = play($players, $last_marble);


print "2018 day9: pl_ans_1: $p1\n";


# -------------------------------------------------
# Part 2
# -------------------------------------------------

my $p2 = play($players, $last_marble * 100);


print "2018 day9: pl_ans_2: $p2\n";

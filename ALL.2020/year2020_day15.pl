#!/usr/bin/perl
use strict;
use warnings;

# ------------------------------------------------------------
# Advent of Code 2020 Day 15
# Part 1 of 2
# ------------------------------------------------------------

sub play_game {

    my ($starting_numbers, $limit) = @_;

    my %last_seen;

    # initialize all except last number
    for (my $i = 0; $i < @$starting_numbers - 1; $i++) {

        my $num = $starting_numbers->[$i];

        # turns are 1-indexed (same as Python)
        $last_seen{$num} = $i + 1;
    }

    my $last = $starting_numbers->[-1];


    for (my $turn = scalar(@$starting_numbers);
         $turn < $limit;
         $turn++) {

        my $next_num;

        if (exists $last_seen{$last}) {

            $next_num = $turn - $last_seen{$last};

        }
        else {

            $next_num = 0;
        }


        $last_seen{$last} = $turn;

        $last = $next_num;
    }


    return $last;
}


sub part1 {

    my ($nums) = @_;

    return play_game($nums, 2020);
}


sub part2 {

    my ($nums) = @_;

    return play_game($nums, 30000000);
}


# ------------------------------------------------------------
# Main input handling in Part 2
# ------------------------------------------------------------

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @input;

while (<$fh>) {

    chomp;

    if (length($_)) {

        @input = split(/,/, $_);
    }
}

close($fh);


@input = map { int($_) } @input;


my $p1 = part1(\@input);

print "2020 day15: pl_ans_1: $p1\n";


my $p2 = part2(\@input);

print "2020 day15: pl_ans_2: $p2\n";

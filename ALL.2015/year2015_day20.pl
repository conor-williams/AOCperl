#!/usr/bin/env perl

use strict;
use warnings;

sub part1 {
    my ($target) = @_;

    my $limit = int($target / 10);

    my @houses = (0) x ($limit + 1);

    for my $elf (1 .. $limit) {

        for (my $house = $elf; $house <= $limit; $house += $elf) {
            $houses[$house] += $elf * 10;
        }
    }

    for my $i (0 .. $#houses) {
        return $i if $houses[$i] >= $target;
    }
}

sub part2 {
    my ($target) = @_;

    my $limit = int($target / 11);

    my @houses = (0) x ($limit + 1);

    for my $elf (1 .. $limit) {

        my $visits = 0;

        for (my $house = $elf; $house <= $limit; $house += $elf) {

            $houses[$house] += $elf * 11;

            $visits++;
            last if $visits == 50;
        }
    }

    for my $i (0 .. $#houses) {
        return $i if $houses[$i] >= $target;
    }
}

sub main {
    open my $fh, '<', $ARGV[0] or die $!;
    my $target = <$fh>;
    close $fh;

    chomp $target;
    $target = int($target);

    my $p1 = part1($target);
    my $p2 = part2($target);

    print "2015 day20: pl_ans_1: $p1\n";
    print "2015 day20: pl_ans_2: $p2\n";
}

main();

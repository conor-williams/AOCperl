#!/usr/bin/perl

use strict;
use warnings;

sub solve {
    my ($offsets, $part2) = @_;

    my @arr = @$offsets;

    my $i = 0;
    my $steps = 0;

    while ($i >= 0 && $i < @arr) {

        my $jump = $arr[$i];

        if ($part2 && $jump >= 3) {
            $arr[$i]--;
        }
        else {
            $arr[$i]++;
        }

        $i += $jump;
        $steps++;
    }

    return $steps;
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @offsets;

    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq "";
        push @offsets, int($line);
    }

    close($fh);

    my $p1 = solve(\@offsets, 0);
    my $p2 = solve(\@offsets, 1);

    print "2017 day5: pl_ans_1: $p1\n";
    print "2017 day5: pl_ans_2: $p2\n";
}

main();

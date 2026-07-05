#!/usr/bin/env perl

use strict;
use warnings;

sub main {
    my $path = $ARGV[0];

    open my $fh, '<', $path or die "Cannot open $path: $!";
    local $/;
    my $s = <$fh>;
    close $fh;

    chomp $s;

    my $floor = 0;
    my $part2;

    my $i = 0;
    foreach my $c (split //, $s) {
        $i++;

        if ($c eq '(') {
            $floor++;
        }
        elsif ($c eq ')') {
            $floor--;
        }

        if (!defined($part2) && $floor < 0) {
            $part2 = $i;
        }
    }

    my $p1 = $floor;
    my $p2 = $part2;

    print "2015 day1: pl_ans_1: $p1\n";
    print "2015 day1: pl_ans_2: $p2\n";
}

main();

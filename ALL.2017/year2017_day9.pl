#!/usr/bin/perl

use strict;
use warnings;

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my $s = "";

    while (<$fh>) {
        chomp;
        $s .= $_;
    }

    close($fh);

    my $i = 0;
    my $depth = 0;
    my $score = 0;
    my $garbage = 0;
    my $garbage_count = 0;

    while ($i < length($s)) {

        my $c = substr($s, $i, 1);

        if ($garbage) {

            if ($c eq "!") {
                $i++;
            }
            elsif ($c eq ">") {
                $garbage = 0;
            }
            else {
                $garbage_count++;
            }

        }
        else {

            if ($c eq "{") {
                $depth++;
            }
            elsif ($c eq "}") {
                $score += $depth;
                $depth--;
            }
            elsif ($c eq "<") {
                $garbage = 1;
            }
        }

        $i++;
    }

    print "2017 day9: pl_ans_1: $score\n";
    print "2017 day9: pl_ans_2: $garbage_count\n";
}

main();

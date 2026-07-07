#!/usr/bin/perl

use strict;
use warnings;

sub redistribute {
    my ($banks) = @_;

    my $n = scalar(@$banks);

    my $i = 0;

    for (my $j = 1; $j < $n; $j++) {
        if ($banks->[$j] > $banks->[$i]) {
            $i = $j;
        }
    }

    my $blocks = $banks->[$i];
    $banks->[$i] = 0;

    while ($blocks) {
        $i = ($i + 1) % $n;
        $banks->[$i]++;
        $blocks--;
    }
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my $text = "";
    while (<$fh>) {
        $text .= $_;
    }

    close($fh);

    my @banks = split(/\s+/, $text);

    my %seen;
    my $steps = 0;

    while (1) {

        my $state = join(",", @banks);

        if (exists $seen{$state}) {

            my $cycle_length = $steps - $seen{$state};

            print "2017 day6: pl_ans_1: $steps\n";
            print "2017 day6: pl_ans_2: $cycle_length\n";
            return;
        }

        $seen{$state} = $steps;

        redistribute(\@banks);

        $steps++;
    }
}

main();

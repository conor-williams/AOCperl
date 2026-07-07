#!/usr/bin/perl

use strict;
use warnings;

sub solve {
    my ($s, $step) = @_;

    my $total = 0;
    my $n = length($s);

    for (my $i = 0; $i < $n; $i++) {
        if (substr($s, $i, 1) eq substr($s, ($i + $step) % $n, 1)) {
            $total += substr($s, $i, 1);
        }
    }

    return $total;
}

sub main {
    my $path = $ARGV[0];

    open(my $fh, "<", $path) or die $!;
    my $s = <$fh>;
    close($fh);

    chomp $s;

    my $p1 = solve($s, 1);
    my $p2 = solve($s, int(length($s) / 2));

    print "2017 day1: pl_ans_1: $p1\n";
    print "2017 day1: pl_ans_2: $p2\n";
}

main();

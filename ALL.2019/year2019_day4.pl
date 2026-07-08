#!/usr/bin/perl

use strict;
use warnings;

sub valid_part1 {

    my ($n) = @_;

    my $s = "$n";

    my $has_double = 0;

    for my $i (0 .. 4) {

        if (substr($s,$i,1) eq substr($s,$i+1,1)) {
            $has_double = 1;
        }

        if (substr($s,$i,1) gt substr($s,$i+1,1)) {
            return 0;
        }
    }

    return $has_double;
}


sub valid_part2 {

    my ($n) = @_;

    my $s = "$n";

    for my $i (0 .. 4) {

        if (substr($s,$i,1) gt substr($s,$i+1,1)) {
            return 0;
        }
    }

    my %counts;

    $counts{$_}++ for split //,$s;

    for my $v (values %counts) {

        return 1 if $v == 2;
    }

    return 0;
}


sub main {

    my $path = $ARGV[0];

    open my $fh,'<',$path or die $!;

    chomp(my $line = <$fh>);

    close $fh;

    my ($a,$b) = map { int($_) } split /-/,$line;

    my $p1 = 0;
    my $p2 = 0;

    for my $n ($a .. $b) {

        $p1++ if valid_part1($n);

        $p2++ if valid_part2($n);
    }

    print "2019 day4: pl_ans_1: $p1\n";
    print "2019 day4: pl_ans_2: $p2\n";
}


main();

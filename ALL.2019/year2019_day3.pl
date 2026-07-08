#!/usr/bin/perl

use strict;
use warnings;

sub trace {

    my ($wire) = @_;

    my $x = 0;
    my $y = 0;

    my $steps = 0;

    my %seen;

    my %dirs = (
        R => [ 1, 0 ],
        L => [ -1, 0 ],
        U => [ 0, 1 ],
        D => [ 0,-1 ],
    );

    for my $ins (@$wire) {

        my $d = substr($ins,0,1);

        my $n = substr($ins,1);

        my ($dx,$dy) = @{$dirs{$d}};

        for (1 .. $n) {

            $x += $dx;
            $y += $dy;

            $steps++;

            my $key = "$x,$y";

            if (!exists $seen{$key}) {

                $seen{$key} = $steps;
            }
        }
    }

    return \%seen;
}


sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die $!;

    chomp(my $line1 = <$fh>);
    chomp(my $line2 = <$fh>);

    close $fh;

    my @w1 = split /,/, $line1;
    my @w2 = split /,/, $line2;

    my $a = trace(\@w1);
    my $b = trace(\@w2);

    my @intersections;

    for my $p (keys %$a) {

        push @intersections, $p
            if exists $b->{$p};
    }

    # Part 1

    my $p1;

    for my $p (@intersections) {

        my ($x,$y) = split /,/,$p;

        my $d = abs($x) + abs($y);

        if (!defined($p1) || $d < $p1) {

            $p1 = $d;
        }
    }

    # Part 2

    my $p2;

    for my $p (@intersections) {

        my $d = $a->{$p} + $b->{$p};

        if (!defined($p2) || $d < $p2) {

            $p2 = $d;
        }
    }

    print "2019 day3: pl_ans_1: $p1\n";
    print "2019 day3: pl_ans_2: $p2\n";
}


main();

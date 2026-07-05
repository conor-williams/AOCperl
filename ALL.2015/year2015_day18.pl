#!/usr/bin/env perl

use strict;
use warnings;

sub neighbors {
    my ($x, $y, $n) = @_;

    my @out;

    for my $dx (-1, 0, 1) {
        for my $dy (-1, 0, 1) {

            next if $dx == 0 && $dy == 0;

            my $nx = $x + $dx;
            my $ny = $y + $dy;

            next if $nx < 0 || $ny < 0 || $nx >= $n || $ny >= $n;

            push @out, [$nx, $ny];
        }
    }

    return @out;
}

sub step {
    my ($grid, $stuck) = @_;

    my $n = @$grid;
    my @new = map { [(0) x $n] } 1 .. $n;

    for my $y (0 .. $n - 1) {
        for my $x (0 .. $n - 1) {

            if ($stuck &&
                (($x == 0 && $y == 0) ||
                 ($x == 0 && $y == $n-1) ||
                 ($x == $n-1 && $y == 0) ||
                 ($x == $n-1 && $y == $n-1))) {
                $new[$y][$x] = 1;
                next;
            }

            my $cnt = 0;

            for my $nref (neighbors($x, $y, $n)) {
                my ($nx, $ny) = @$nref;
                $cnt += $grid->[$ny][$nx];
            }

            if ($grid->[$y][$x]) {
                $new[$y][$x] = ($cnt == 2 || $cnt == 3) ? 1 : 0;
            }
            else {
                $new[$y][$x] = ($cnt == 3) ? 1 : 0;
            }
        }
    }

    return \@new;
}

sub solve {
    my ($grid, $steps, $stuck) = @_;

    my $n = @$grid;

    if ($stuck) {
        $grid->[0][0] = 1;
        $grid->[0][$n-1] = 1;
        $grid->[$n-1][0] = 1;
        $grid->[$n-1][$n-1] = 1;
    }

    for (1 .. $steps) {
        $grid = step($grid, $stuck);
    }

    my $sum = 0;
    for my $row (@$grid) {
        $sum += $_ for @$row;
    }

    return $sum;
}

sub main {
    open my $fh, '<', $ARGV[0] or die $!;
    my @grid;

    while (<$fh>) {
        chomp;
        next unless length;
        push @grid, [ map { $_ eq '#' ? 1 : 0 } split // ];
    }
    close $fh;

    my $p1 = solve([ map { [@$_] } @grid ], 100, 0);
    my $p2 = solve([ map { [@$_] } @grid ], 100, 1);

    print "2015 day18: pl_ans_1: $p1\n";
    print "2015 day18: pl_ans_2: $p2\n";
}
main();

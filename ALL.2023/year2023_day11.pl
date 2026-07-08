#!/usr/bin/perl
use strict;
use warnings;

sub solve {
    my ($expansion, $path) = @_;

    open my $fh, "<", $path or die "$path: $!";

    my @grid;

    while (<$fh>) {
        chomp;
        push @grid, [split //] if /\S/;
    }

    close $fh;

    my $h = scalar @grid;
    my $w = scalar @{ $grid[0] };

    my @galaxies;

    my @empty_rows;
    my @empty_cols;

    for my $y (0 .. $h - 1) {
        my $empty = 1;

        for my $x (0 .. $w - 1) {
            $empty = 0 if $grid[$y][$x] ne ".";
        }

        push @empty_rows, $empty;
    }

    for my $x (0 .. $w - 1) {
        my $empty = 1;

        for my $y (0 .. $h - 1) {
            $empty = 0 if $grid[$y][$x] ne ".";
        }

        push @empty_cols, $empty;
    }

    my @row_offset = (0) x $h;
    my @col_offset = (0) x $w;

    for my $i (1 .. $h - 1) {
        $row_offset[$i] =
            $row_offset[$i-1] +
            ($empty_rows[$i-1] ? $expansion : 1);
    }

    for my $i (1 .. $w - 1) {
        $col_offset[$i] =
            $col_offset[$i-1] +
            ($empty_cols[$i-1] ? $expansion : 1);
    }

    for my $y (0 .. $h - 1) {
        for my $x (0 .. $w - 1) {
            if ($grid[$y][$x] eq "#") {
                push @galaxies, [
                    $col_offset[$x],
                    $row_offset[$y]
                ];
            }
        }
    }

    my $total = 0;

    for my $i (0 .. $#galaxies) {
        for my $j ($i+1 .. $#galaxies) {

            my ($x1,$y1) = @{ $galaxies[$i] };
            my ($x2,$y2) = @{ $galaxies[$j] };

            $total += abs($x1-$x2) + abs($y1-$y2);
        }
    }

    return $total;
}

sub main {
    my $path = $ARGV[0];

    my $p1 = solve(2, $path);
    my $p2 = solve(1_000_000, $path);

    print "2023 day11: pl_ans_1: $p1\n";
    print "2023 day11: pl_ans_2: $p2\n";
}

main();

#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

open(my $fh, "<", $file) or die $!;

my @grid;

while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @grid, [ map { int($_) } split // ];
}

my $h = scalar @grid;
my $w = scalar @{ $grid[0] };

# ---------------- Part 1 ----------------

my $visible = 0;

for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        my $v = $grid[$y][$x];

        my ($left,$right,$up,$down) = (1,1,1,1);

        for my $i (0 .. $x-1) {
            if ($grid[$y][$i] >= $v) {
                $left = 0;
                last;
            }
        }

        for my $i ($x+1 .. $w-1) {
            if ($grid[$y][$i] >= $v) {
                $right = 0;
                last;
            }
        }

        for my $i (0 .. $y-1) {
            if ($grid[$i][$x] >= $v) {
                $up = 0;
                last;
            }
        }

        for my $i ($y+1 .. $h-1) {
            if ($grid[$i][$x] >= $v) {
                $down = 0;
                last;
            }
        }

        $visible++ if $left || $right || $up || $down;
    }
}

my $p1 = $visible;

# ---------------- Part 2 ----------------

my $best = 0;

for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        my $v = $grid[$y][$x];

        my ($l,$r,$u,$d) = (0,0,0,0);

        # left
        for (my $i=$x-1;$i>=0;$i--) {
            $l++;
            last if $grid[$y][$i] >= $v;
        }

        # right
        for my $i ($x+1 .. $w-1) {
            $r++;
            last if $grid[$y][$i] >= $v;
        }

        # up
        for (my $i=$y-1;$i>=0;$i--) {
            $u++;
            last if $grid[$i][$x] >= $v;
        }

        # down
        for my $i ($y+1 .. $h-1) {
            $d++;
            last if $grid[$i][$x] >= $v;
        }

        my $score = $l * $r * $u * $d;
        $best = $score if $score > $best;
    }
}

my $p2 = $best;

print "2022 day8: pl_ans_1: $p1\n";
print "2022 day8: pl_ans_2: $p2\n";

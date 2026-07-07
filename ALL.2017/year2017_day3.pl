#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(ceil);

sub manhattan {
    my ($x, $y) = @_;
    return abs($x) + abs($y);
}

sub part1 {
    my ($n) = @_;

    # find spiral layer
    my $k = ceil((sqrt($n) - 1) / 2);
    my $side_len = 2 * $k + 1;
    my $max_val = $side_len ** 2;

    # position on ring
    my $steps_from_corner = $max_val - $n;
    my $side = int($steps_from_corner / ($side_len - 1));
    my $offset = $steps_from_corner % ($side_len - 1);

    my ($x, $y);

    if ($side == 0) {      # right
        $x = $k;
        $y = -$k + $offset;
    }
    elsif ($side == 1) {   # top
        $x = $k - $offset;
        $y = $k;
    }
    elsif ($side == 2) {   # left
        $x = -$k;
        $y = $k - $offset;
    }
    else {                 # bottom
        $x = -$k + $offset;
        $y = -$k;
    }

    return manhattan($x, $y);
}

sub part2 {
    my ($n) = @_;

    my %grid;
    $grid{"0,0"} = 1;

    my $x = 0;
    my $y = 0;

    my $dx = 1;
    my $dy = 0;

    my $steps = 1;

    while (1) {

        for (1 .. 2) {

            for (1 .. $steps) {

                $x += $dx;
                $y += $dy;

                my $val = 0;

                for my $nx ($x - 1 .. $x + 1) {
                    for my $ny ($y - 1 .. $y + 1) {

                        next if $nx == $x && $ny == $y;

                        $val += $grid{"$nx,$ny"} // 0;
                    }
                }

                $grid{"$x,$y"} = $val;

                if ($val > $n) {
                    return $val;
                }
            }

            my $tmp = $dx;
            $dx = -$dy;
            $dy = $tmp;
        }

        $steps++;
    }
}

sub main {

    my $path = $ARGV[0];

    open(my $fh, "<", $path) or die $!;
    my $n = <$fh>;
    close($fh);

    chomp $n;

    my $p1 = part1($n);
    my $p2 = part2($n);

    print "2017 day3: pl_ans_1: $p1\n";
    print "2017 day3: pl_ans_2: $p2\n";
}

main();

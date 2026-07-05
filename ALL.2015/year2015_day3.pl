#!/usr/bin/env perl

use strict;
use warnings;

sub walk {
    my ($directions, $part2) = @_;

    my ($x, $y) = (0, 0);

    my %visited;
    $visited{"0,0"} = 1;

    if ($part2) {

        my ($rx, $ry) = (0, 0);

        my @chars = split //, $directions;

        for (my $i = 0; $i < @chars; $i++) {

            my $c = $chars[$i];

            my ($dx, $dy) = (0, 0);

            if ($c eq '^') {
                $dy = 1;
            }
            elsif ($c eq 'v') {
                $dy = -1;
            }
            elsif ($c eq '>') {
                $dx = 1;
            }
            elsif ($c eq '<') {
                $dx = -1;
            }

            if ($i % 2 == 0) {
                $rx += $dx;
                $ry += $dy;
                $visited{"$rx,$ry"} = 1;
            }
            else {
                $x += $dx;
                $y += $dy;
                $visited{"$x,$y"} = 1;
            }
        }

        return scalar keys %visited;
    }
    else {

        foreach my $c (split //, $directions) {

            if ($c eq '^') {
                $y++;
            }
            elsif ($c eq 'v') {
                $y--;
            }
            elsif ($c eq '>') {
                $x++;
            }
            elsif ($c eq '<') {
                $x--;
            }

            $visited{"$x,$y"} = 1;
        }

        return scalar keys %visited;
    }
}

sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die "Cannot open $path: $!";
    local $/;
    my $data = <$fh>;
    close $fh;

    chomp $data;

    my $p1 = walk($data, 0);
    my $p2 = walk($data, 1);

    print "2015 day3: pl_ans_1: $p1\n";
    print "2015 day3: pl_ans_2: $p2\n";
}

main();

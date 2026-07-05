#!/usr/bin/env perl

use strict;
use warnings;

sub parse {
    my ($line) = @_;

    my @nums = ($line =~ /(\d+)/g);

    my $cmd;

    if ($line =~ /toggle/) {
        $cmd = "toggle";
    }
    elsif ($line =~ /turn on/) {
        $cmd = "on";
    }
    else {
        $cmd = "off";
    }

    return ($cmd, @nums);
}

sub main {

    open my $fh, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!";

    my @lines;

    while (<$fh>) {
        chomp;
        next unless length;
        push @lines, $_;
    }

    close $fh;

    # Part 1

    my @grid = map { [(0) x 1000] } 1 .. 1000;

    foreach my $line (@lines) {

        my ($cmd, $x1, $y1, $x2, $y2) = parse($line);

        for my $y ($y1 .. $y2) {

            my $row = $grid[$y];

            for my $x ($x1 .. $x2) {

                if ($cmd eq "on") {
                    $row->[$x] = 1;
                }
                elsif ($cmd eq "off") {
                    $row->[$x] = 0;
                }
                else {
                    $row->[$x] ^= 1;
                }
            }
        }
    }

    my $p1 = 0;

    foreach my $row (@grid) {
        $p1 += $_ for @$row;
    }

    # Part 2

    @grid = map { [(0) x 1000] } 1 .. 1000;

    foreach my $line (@lines) {

        my ($cmd, $x1, $y1, $x2, $y2) = parse($line);

        for my $y ($y1 .. $y2) {

            my $row = $grid[$y];

            for my $x ($x1 .. $x2) {

                if ($cmd eq "on") {
                    $row->[$x]++;
                }
                elsif ($cmd eq "off") {
                    $row->[$x]-- if $row->[$x] > 0;
                }
                else {
                    $row->[$x] += 2;
                }
            }
        }
    }

    my $p2 = 0;

    foreach my $row (@grid) {
        $p2 += $_ for @$row;
    }

    print "2015 day6: pl_ans_1: $p1\n";
    print "2015 day6: pl_ans_2: $p2\n";
}

main();

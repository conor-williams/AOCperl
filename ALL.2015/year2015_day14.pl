#!/usr/bin/env perl

use strict;
use warnings;

sub parse_input {
    my ($file) = @_;

    my %reindeer;

    open my $fh, '<', $file or die $!;

    while (<$fh>) {

        chomp;
        my @p = split / /;

        my $name = $p[0];
        my $speed = $p[3];
        my $fly   = $p[6];
        my $rest  = $p[13];

        $reindeer{$name} = [$speed, $fly, $rest];
    }

    close $fh;

    return \%reindeer;
}

sub get_distance {
    my ($r, $t) = @_;

    my ($speed, $fly, $rest) = @$r;

    my $cycle = $fly + $rest;

    my $full = int($t / $cycle);
    my $rem  = $t % $cycle;

    my $flying = $full * $fly + ($rem < $fly ? $rem : $fly);

    return $flying * $speed;
}

sub day14 {
    my ($reindeer, $total_time) = @_;

    my @names = sort keys %$reindeer;

    my @points = (0) x @names;

    my @distances;
    for my $t (1 .. $total_time) {

        @distances = map {
            get_distance($reindeer->{$_}, $t)
        } @names;

        my $lead = 0;
        $lead = $_ > $lead ? $_ : $lead for @distances;

        for my $i (0 .. $#names) {
            $points[$i]++ if $distances[$i] == $lead;
        }
    }

    my $max_dist = 0;
    my $max_pts  = 0;

    foreach my $d (@distances) {
        $max_dist = $d if $d > $max_dist;
    }

    $max_pts = $points[0];
    for (@points) {
        $max_pts = $_ if $_ > $max_pts;
    }

    return ($max_dist, $max_pts);
}

sub main {
    my $file = $ARGV[0];

    my $reindeer = parse_input($file);

    my ($p1, $p2) = day14($reindeer, 2503);

    print "2015 day14: pl_ans_1: $p1\n";
    print "2015 day14: pl_ans_2: $p2\n";
}

main();

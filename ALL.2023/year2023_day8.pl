#!/usr/bin/perl
use strict;
use warnings;

sub gcd {
    my ($a, $b) = @_;

    while ($b != 0) {
        ($a, $b) = ($b, $a % $b);
    }

    return $a;
}

sub lcm {
    my ($a, $b) = @_;

    return int($a / gcd($a, $b) * $b);
}

sub steps {
    my ($start, $instr, $graph, $part2) = @_;

    my $cur = $start;
    my $i = 0;
    my $n = length($instr);

    while (1) {

        if ((!$part2 && $cur eq "ZZZ") ||
            ($part2 && $cur =~ /Z$/)) {
            return $i;
        }

        my $d = substr($instr, $i % $n, 1);

        if ($d eq "L") {
            $cur = $graph->{$cur}->[0];
        }
        else {
            $cur = $graph->{$cur}->[1];
        }

        $i++;
    }
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @lines;
    while (<$fh>) {
        chomp;
        push @lines, $_ if /\S/;
    }

    close $fh;

    my $instr = shift @lines;

    my %graph;

    for my $line (@lines) {
        my @nodes = ($line =~ /(\w+)/g);

        $graph{$nodes[0]} = [
            $nodes[1],
            $nodes[2]
        ];
    }

    # Part 1
    my $p1 = steps("AAA", $instr, \%graph, 0);

    # Part 2
    my @starts;

    for my $node (keys %graph) {
        push @starts, $node if $node =~ /A$/;
    }

    my @vals;

    for my $s (@starts) {
        push @vals, steps($s, $instr, \%graph, 1);
    }

    my $p2 = shift @vals;

    for my $v (@vals) {
        $p2 = lcm($p2, $v);
    }

    print "2023 day8: pl_ans_1: $p1\n";
    print "2023 day8: pl_ans_2: $p2\n";
}

main();

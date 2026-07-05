#!/usr/bin/env perl

use strict;
use warnings;

sub permutations {
    my ($items) = @_;

    return [[]] unless @$items;

    my @result;

    for my $i (0 .. $#$items) {

        my @rest = @$items;
        my $item = splice(@rest, $i, 1);

        foreach my $perm (@{ permutations(\@rest) }) {
            push @result, [$item, @$perm];
        }
    }

    return \@result;
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

    my %dist;
    my %cities;

    foreach my $line (@lines) {

        my ($a, $b, $d) = ($line =~ /(\w+) to (\w+) = (\d+)/);

        $dist{$a}{$b} = $d;
        $dist{$b}{$a} = $d;

        $cities{$a} = 1;
        $cities{$b} = 1;
    }

    my @cities = keys %cities;

    my $best  = 1e99;
    my $worst = 0;

    foreach my $perm (@{ permutations(\@cities) }) {

        my $total = 0;
        my $ok = 1;

        for my $i (0 .. $#$perm - 1) {

            my $a = $perm->[$i];
            my $b = $perm->[$i + 1];

            unless (exists $dist{$a}{$b}) {
                $ok = 0;
                last;
            }

            $total += $dist{$a}{$b};
        }

        next unless $ok;

        $best  = $total if $total < $best;
        $worst = $total if $total > $worst;
    }

    print "2015 day9: pl_ans_1: $best\n";
    print "2015 day9: pl_ans_2: $worst\n";
}

main();

#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max);

sub parse_input {
    my ($lines) = @_;

    my %happiness;

    foreach my $line (@$lines) {

        $line =~ s/\.$//;
        my @parts = split / /, $line;

        my $person   = $parts[0];
        my $neighbor = $parts[-1];

        my $value = $parts[3];
        $value = -$value if $parts[2] eq "lose";

        $happiness{$person}{$neighbor} = $value;
    }

    return \%happiness;
}

sub total_happiness {
    my ($order, $happiness) = @_;

    my $total = 0;
    my $n = @$order;

    for my $i (0 .. $n - 1) {

        my $a = $order->[$i];
        my $b = $order->[($i + 1) % $n];

        $total += $happiness->{$a}{$b} // 0;
        $total += $happiness->{$b}{$a} // 0;
    }

    return $total;
}

sub permutations {
    my ($items) = @_;

    return [[]] unless @$items;

    my @res;

    for my $i (0 .. $#$items) {

        my @rest = @$items;
        my $item = splice(@rest, $i, 1);

        for my $p (@{ permutations(\@rest) }) {
            push @res, [$item, @$p];
        }
    }

    return \@res;
}

sub solve {
    my ($happiness) = @_;

    my @people = keys %$happiness;

    my $best = -1e18;

    foreach my $perm (@{ permutations(\@people) }) {
        $best = max($best, total_happiness($perm, $happiness));
    }

    print "2015 day13: pl_ans_1: $best\n";

    # Part 2
    my $me = "You";
    $happiness->{$me} = {};

    foreach my $p (@people) {
        $happiness->{$p}{$me} = 0;
        $happiness->{$me}{$p} = 0;
    }

    push @people, $me;

    my $best2 = -1e18;

    foreach my $perm (@{ permutations(\@people) }) {
        $best2 = max($best2, total_happiness($perm, $happiness));
    }

    print "2015 day13: pl_ans_2: $best2\n";
}

sub main {
    open my $fh, '<', $ARGV[0] or die $!;
    my @lines = <$fh>;
    chomp @lines;
    close $fh;

    my $happiness = parse_input(\@lines);
    solve($happiness);
}

main();

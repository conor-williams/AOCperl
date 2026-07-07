#!/usr/bin/perl

use strict;
use warnings;

sub dfs {
    my ($node, $weight, $children) = @_;

    if (!exists $children->{$node}) {
        return ($weight->{$node}, undef);
    }

    my @totals;

    foreach my $c (@{$children->{$node}}) {
        my ($tw, $bad) = dfs($c, $weight, $children);

        if (defined $bad) {
            return (0, $bad);
        }

        push @totals, [$c, $tw];
    }

    my @ws = map { $_->[1] } @totals;

    my %uniq;
    $uniq{$_} = 1 for @ws;

    if (keys(%uniq) > 1) {

        my %freq;

        foreach my $t (@totals) {
            $freq{$t->[1]}++;
        }

        my ($correct, $wrong);

        foreach my $k (keys %freq) {
            if (!defined($correct) || $freq{$k} > $freq{$correct}) {
                $correct = $k;
            }
            if (!defined($wrong) || $freq{$k} < $freq{$wrong}) {
                $wrong = $k;
            }
        }

        my $bad_node;

        foreach my $t (@totals) {
            if ($t->[1] == $wrong) {
                $bad_node = $t->[0];
            }
        }

        my $diff = $correct - $wrong;

        return (0, $weight->{$bad_node} + $diff);
    }

    my $sum = 0;
    $sum += $_ for @ws;

    return ($weight->{$node} + $sum, undef);
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines;

    while (<$fh>) {
        chomp;
        next if $_ eq "";
        push @lines, $_;
    }

    close($fh);

    my %weight;
    my %children;
    my %all_nodes;
    my %child_nodes;

    foreach my $line (@lines) {

        my @parts = split(/->/, $line);

        my $left = $parts[0];
        $left =~ s/^\s+|\s+$//g;

        $left =~ /(\w+) \((\d+)\)/;

        my $name = $1;
        my $w = int($2);

        $weight{$name} = $w;
        $all_nodes{$name} = 1;

        if (@parts > 1) {

            my @kids = map {
                s/^\s+|\s+$//gr
            } split(/,/, $parts[1]);

            $children{$name} = \@kids;

            foreach my $k (@kids) {
                $child_nodes{$k} = 1;
            }
        }
    }

    my $root;

    foreach my $n (keys %all_nodes) {
        if (!exists $child_nodes{$n}) {
            $root = $n;
            last;
        }
    }

    my ($dummy, $p2) = dfs($root, \%weight, \%children);

    print "2017 day7: pl_ans_1: $root\n";
    print "2017 day7: pl_ans_2: $p2\n";
}

main();

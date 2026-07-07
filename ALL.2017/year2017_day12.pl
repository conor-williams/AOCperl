#!/usr/bin/perl

use strict;
use warnings;

sub parse {

    my %graph;

    my $file = $ARGV[0];

    open(my $fh, "<", $file) or die;

    while (my $line = <$fh>) {

        chomp $line;

        next if $line eq "";

        my ($left, $right) = split(/ <-> /, $line);

        my $a = int($left);

        my @bs = split(/,/, $right);

        foreach my $b (@bs) {

            $b = int($b);

            push @{$graph{$a}}, $b;
            push @{$graph{$b}}, $a;
        }
    }

    close($fh);

    return %graph;
}


sub bfs {

    my ($start, $graph_ref, $seen_ref) = @_;

    my @q = ($start);
    my %group;

    while (@q) {

        my $node = shift @q;

        next if exists $seen_ref->{$node};

        $seen_ref->{$node} = 1;
        $group{$node} = 1;

        foreach my $nxt (@{$graph_ref->{$node}}) {

            if (!exists $seen_ref->{$nxt}) {
                push @q, $nxt;
            }
        }
    }

    return %group;
}


# ---------------- Part 1 / Part 2 ----------------

my %graph = parse();


my %seen;

my %group0 = bfs(0, \%graph, \%seen);

my $p1 = scalar(keys %group0);


%seen = ();

my $groups = 0;


foreach my $node (keys %graph) {

    if (!exists $seen{$node}) {

        bfs($node, \%graph, \%seen);

        $groups++;
    }
}


my $p2 = $groups;


print "2017 day12: pl_ans_1: $p1\n";
print "2017 day12: pl_ans_2: $p2\n";

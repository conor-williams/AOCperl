#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';


sub build_graph {

    my ($lines) = @_;

    my %parent;
    my %children;

    for my $line (@$lines) {

        my ($a, $b) = split /\)/, $line;

        $parent{$b} = $a;

        push @{$children{$a}}, $b;
    }

    return (\%parent, \%children);
}


sub count_orbits {

    my ($parent) = @_;

    my %memo;

    my $depth;

    $depth = sub {

        my ($node) = @_;

        if (!exists $parent->{$node}) {
            return 0;
        }

        if (exists $memo{$node}) {
            return $memo{$node};
        }

        $memo{$node} =
            1 + $depth->($parent->{$node});

        return $memo{$node};
    };

    my $sum = 0;

    for my $node (keys %$parent) {

        $sum += $depth->($node);
    }

    return $sum;
}


sub build_undirected {

    my ($parent) = @_;

    my %graph;

    while (my ($child, $par) = each %$parent) {

        push @{$graph{$child}}, $par;
        push @{$graph{$par}},   $child;
    }

    return \%graph;
}


sub bfs {

    my ($graph, $start, $target) = @_;

    my @queue = ([$start, 0]);

    my %seen;

    my $head = 0;

    while ($head < @queue) {

        my ($node, $dist) = @{$queue[$head++]};

        if ($node eq $target) {
            return $dist;
        }

        next if $seen{$node};

        $seen{$node} = 1;

        for my $next (@{$graph->{$node} || []}) {

            push @queue, [$next, $dist + 1];
        }
    }

    return undef;
}


sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die $!;

    my @lines;

    while (<$fh>) {

        chomp;

        next unless /\S/;

        push @lines, $_;
    }

    close $fh;

    my ($parent, $children) = build_graph(\@lines);

    # Part 1
    my $p1 = count_orbits($parent);

    # Part 2
    my $graph = build_undirected($parent);

    my $p2 =
        bfs(
            $graph,
            $parent->{YOU},
            $parent->{SAN}
        );

    print "2019 day6: pl_ans_1: $p1\n";
    print "2019 day6: pl_ans_2: $p2\n";
}


main();

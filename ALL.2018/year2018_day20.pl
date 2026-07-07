#!/usr/bin/perl

use strict;
use warnings;

use constant
{
    NORTH => [0, -1],
    SOUTH => [0,  1],
    EAST  => [1,  0],
    WEST  => [-1, 0],
};


# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file)
    or die "Cannot open $file: $!";

my $regex = <$fh>;

close($fh);

chomp $regex;


# -------------------------------------------------
# Build graph
# -------------------------------------------------

sub build_graph
{
    my ($regex) = @_;


    my %graph;


    my %positions;
    $positions{"0,0"} = [0,0];


    my @stack;


    my %dirs =
    (
        N => [0,-1],
        S => [0,1],
        E => [1,0],
        W => [-1,0],
    );


    my @chars = split //, substr($regex,1,-1);


    for my $c (@chars)
    {
        if (exists $dirs{$c})
        {
            my ($dx,$dy) = @{$dirs{$c}};


            my %new_positions;


            for my $key (keys %positions)
            {
                my ($x,$y) = @{$positions{$key}};


                my $nx = $x + $dx;
                my $ny = $y + $dy;


                $graph{$key}{$nx.",".$ny} = 1;
                $graph{$nx.",".$ny}{$key} = 1;


                $new_positions{$nx.",".$ny} =
                    [$nx,$ny];
            }


            %positions = %new_positions;
        }

        elsif ($c eq '(')
        {
            push @stack,
            [
                { %positions },
                {}
            ];
        }

        elsif ($c eq '|')
        {
            my ($start,$ends) = @{$stack[-1]};


            for my $p (keys %positions)
            {
                $ends->{$p} = $positions{$p};
            }


            %positions = %$start;
        }

        elsif ($c eq ')')
        {
            my ($start,$ends) = @{pop @stack};


            for my $p (keys %positions)
            {
                $ends->{$p} = $positions{$p};
            }


            %positions = %$ends;
        }
    }


    return \%graph;
}


# -------------------------------------------------
# BFS distances
# -------------------------------------------------

sub bfs
{
    my ($graph) = @_;


    my %dist;

    $dist{"0,0"} = 0;


    my @queue = ("0,0");


    while (@queue)
    {
        my $cur = shift @queue;


        for my $next (keys %{$graph->{$cur}})
        {
            next if exists $dist{$next};


            $dist{$next} = $dist{$cur} + 1;


            push @queue, $next;
        }
    }


    return \%dist;
}


# -------------------------------------------------
# Solve
# -------------------------------------------------

my $graph = build_graph($regex);

my $dist = bfs($graph);


my $p1 = 0;
my $p2 = 0;


for my $d (values %$dist)
{
    $p1 = $d if $d > $p1;

    $p2++ if $d >= 1000;
}


print "2018 day20: pl_ans_1: $p1\n";
print "2018 day20: pl_ans_2: $p2\n";

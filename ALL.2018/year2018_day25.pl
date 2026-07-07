#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Parsing
# -------------------------------------------------

my $file = shift @ARGV
    or die "Usage: $0 input.txt\n";


open(my $fh, '<', $file)
    or die "Cannot open $file: $!";


my @points;


while (my $line = <$fh>)
{
    chomp $line;

    next if $line =~ /^\s*$/;


    my @p = split(/,/, $line);


    push @points,
    [
        int($p[0]),
        int($p[1]),
        int($p[2]),
        int($p[3])
    ];
}


close($fh);



# -------------------------------------------------
# 4D Manhattan distance
# -------------------------------------------------

sub dist
{
    my ($a,$b)=@_;


    return
        abs($a->[0]-$b->[0]) +
        abs($a->[1]-$b->[1]) +
        abs($a->[2]-$b->[2]) +
        abs($a->[3]-$b->[3]);
}



# -------------------------------------------------
# Build graph
# -------------------------------------------------

sub build_graph
{
    my ($points)=@_;


    my $n=@$points;


    my @graph;


    for my $i (0 .. $n-1)
    {
        $graph[$i]=[];
    }



    for my $i (0 .. $n-1)
    {
        for my $j ($i+1 .. $n-1)
        {
            if (dist($points->[$i],$points->[$j]) <= 3)
            {
                push @{$graph[$i]},$j;
                push @{$graph[$j]},$i;
            }
        }
    }


    return \@graph;
}



# -------------------------------------------------
# Count connected components
# -------------------------------------------------

sub count_constellations
{
    my ($graph)=@_;


    my $n=@$graph;


    my @visited =
        (0) x $n;


    my $count=0;



    for my $i (0 .. $n-1)
    {
        next if $visited[$i];


        $count++;


        my @queue=($i);

        $visited[$i]=1;



        while (@queue)
        {
            my $cur=shift @queue;


            for my $next (@{$graph->[$cur]})
            {
                next if $visited[$next];


                $visited[$next]=1;

                push @queue,$next;
            }
        }
    }


    return $count;
}



# -------------------------------------------------
# Main
# -------------------------------------------------

my $graph =
    build_graph(\@points);


my $answer =
    count_constellations($graph);


print "2018 day25: pl_ans_1: $answer\n";

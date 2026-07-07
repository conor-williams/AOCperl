#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Constants
# -------------------------------------------------

use constant
{
    ROCKY   => 0,
    WET     => 1,
    NARROW  => 2,

    TORCH    => 0,
    CLIMBING => 1,
    NEITHER  => 2,
};


my %ALLOWED =
(
    ROCKY()  => { TORCH() => 1, CLIMBING() => 1 },
    WET()    => { CLIMBING() => 1, NEITHER() => 1 },
    NARROW() => { TORCH() => 1, NEITHER() => 1 },
);


# -------------------------------------------------
# Input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file)
    or die "Cannot open $file: $!";


my @lines =
    grep { /\S/ } <$fh>;

close($fh);


chomp @lines;


my ($depth) =
    $lines[0] =~ /(\d+)/;


my ($tx, $ty) =
    $lines[1] =~ /(\d+),(\d+)/;


# -------------------------------------------------
# Caches
# -------------------------------------------------

my %erosion_cache;


# -------------------------------------------------
# Erosion
# -------------------------------------------------

sub erosion_level
{
    my ($x, $y) = @_;


    my $key = "$x,$y";


    return $erosion_cache{$key}
        if exists $erosion_cache{$key};


    my $geo;


    if ($x == 0 && $y == 0)
    {
        $geo = 0;
    }
    elsif ($x == $tx && $y == $ty)
    {
        $geo = 0;
    }
    elsif ($y == 0)
    {
        $geo = $x * 16807;
    }
    elsif ($x == 0)
    {
        $geo = $y * 48271;
    }
    else
    {
        $geo =
            erosion_level($x - 1, $y) *
            erosion_level($x, $y - 1);
    }


    my $erosion =
        ($geo + $depth) % 20183;


    $erosion_cache{$key} = $erosion;


    return $erosion;
}


sub region_type
{
    my ($x,$y) = @_;

    return erosion_level($x,$y) % 3;
}


# -------------------------------------------------
# Part 1
# -------------------------------------------------

sub solve_part1
{
    my $total = 0;


    for my $y (0 .. $ty)
    {
        for my $x (0 .. $tx)
        {
            $total += region_type($x,$y);
        }
    }


    return $total;
}


# -------------------------------------------------
# Binary heap
# -------------------------------------------------

sub heap_push
{
    my ($heap, $item) = @_;


    push @$heap, $item;


    my $i = @$heap - 1;


    while ($i > 0)
    {
        my $p = int(($i - 1) / 2);


        last if $heap->[$p][0] <= $heap->[$i][0];


        ($heap->[$p], $heap->[$i]) =
            ($heap->[$i], $heap->[$p]);


        $i = $p;
    }
}


sub heap_pop
{
    my ($heap) = @_;


    my $result = $heap->[0];


    my $last = pop @$heap;


    if (@$heap)
    {
        $heap->[0] = $last;


        my $i = 0;


        while (1)
        {
            my $left  = $i * 2 + 1;
            my $right = $i * 2 + 2;

            my $small = $i;


            if ($left < @$heap &&
                $heap->[$left][0] < $heap->[$small][0])
            {
                $small = $left;
            }


            if ($right < @$heap &&
                $heap->[$right][0] < $heap->[$small][0])
            {
                $small = $right;
            }


            last if $small == $i;


            ($heap->[$i], $heap->[$small]) =
                ($heap->[$small], $heap->[$i]);


            $i = $small;
        }
    }


    return $result;
}


# -------------------------------------------------
# Part 2 Dijkstra
# -------------------------------------------------

sub solve_part2
{
    my @heap;


    # time,x,y,tool
    heap_push(
        \@heap,
        [0,0,0,TORCH()]
    );


    my %visited;


    my $max_x = $tx + 100;
    my $max_y = $ty + 100;


    while (@heap)
    {
        my ($time,$x,$y,$tool) =
            @{heap_pop(\@heap)};


        my $state =
            "$x,$y,$tool";


        next if exists $visited{$state}
             && $visited{$state} <= $time;


        $visited{$state} = $time;


        if ($x == $tx &&
            $y == $ty &&
            $tool == TORCH)
        {
            return $time;
        }


        my $region =
            region_type($x,$y);


        # Change tool
        for my $new_tool (keys %{$ALLOWED{$region}})
        {
            next if $new_tool == $tool;


            heap_push(
                \@heap,
                [
                    $time + 7,
                    $x,
                    $y,
                    $new_tool
                ]
            );
        }


        # Move
        for my $dir
        (
            [-1,0],
            [1,0],
            [0,-1],
            [0,1]
        )
        {
            my $nx = $x + $dir->[0];
            my $ny = $y + $dir->[1];


            next if $nx < 0 || $ny < 0;
            next if $nx > $max_x || $ny > $max_y;


            my $next_region =
                region_type($nx,$ny);


            if ($ALLOWED{$next_region}{$tool})
            {
                heap_push(
                    \@heap,
                    [
                        $time + 1,
                        $nx,
                        $ny,
                        $tool
                    ]
                );
            }
        }
    }
}


# -------------------------------------------------
# Main
# -------------------------------------------------

my $p1 = solve_part1();
my $p2 = solve_part2();


print "2018 day22: pl_ans_1: $p1\n";
print "2018 day22: pl_ans_2: $p2\n";

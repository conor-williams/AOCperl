#!/usr/bin/perl

use strict;
use warnings;

no warnings 'recursion';
# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my @lines = <$fh>;

close($fh);


# -------------------------------------------------
# Parse clay data
# -------------------------------------------------

my @data;

for my $line (@lines)
{
    chomp $line;

    my @nums = ($line =~ /\d+/g);

    my ($a, $b, $c) = @nums;


    if ($line =~ /^x/)
    {
        push @data, [$a, $a, $b, $c];
    }
    else
    {
        push @data, [$b, $c, $a, $a];
    }
}


# -------------------------------------------------
# Find bounds
# -------------------------------------------------

my $minX = $data[0][0];
my $maxX = $data[0][1];
my $minY = $data[0][2];
my $maxY = $data[0][3];


for my $d (@data)
{
    $minX = $d->[0] if $d->[0] < $minX;
    $maxX = $d->[1] if $d->[1] > $maxX;

    $minY = $d->[2] if $d->[2] < $minY;
    $maxY = $d->[3] if $d->[3] > $maxY;
}


# -------------------------------------------------
# Create grid
# -------------------------------------------------

my $width = $maxX - $minX + 2;


my @grid;

for my $y (0 .. $maxY)
{
    $grid[$y] = [ ('.') x $width ];
}


# -------------------------------------------------
# Place clay
# -------------------------------------------------

for my $d (@data)
{
    my ($x1, $x2, $y1, $y2) = @$d;


    for my $x ($x1 .. $x2)
    {
        for my $y ($y1 .. $y2)
        {
            $grid[$y][$x - $minX + 1] = '#';
        }
    }
}


# -------------------------------------------------
# Spring
# -------------------------------------------------

my $springX = 500 - $minX + 1;
my $springY = 0;

$grid[$springY][$springX] = '+';


# -------------------------------------------------
# Recursive water flow
# -------------------------------------------------

sub flow
{
    my ($grid, $x, $y, $d) = @_;


    if ($grid->[$y][$x] eq '.')
    {
        $grid->[$y][$x] = '|';
    }


    # Bottom of grid
    if ($y == $#$grid)
    {
        return;
    }


    # Hit clay
    if ($grid->[$y][$x] eq '#')
    {
        return $x;
    }


    # Flow down
    if ($grid->[$y + 1][$x] eq '.')
    {
        flow($grid, $x, $y + 1, 0);
    }


    # Supported below
    if ($grid->[$y + 1][$x] eq '~' ||
        $grid->[$y + 1][$x] eq '#')
    {

        if ($d)
        {
            return flow($grid, $x + $d, $y, $d);
        }
        else
        {
            my $leftX =
                flow($grid, $x - 1, $y, -1);

            my $rightX =
                flow($grid, $x + 1, $y, 1);


            if ($grid->[$y][$leftX] eq '#' &&
                $grid->[$y][$rightX] eq '#')
            {
                for my $fillX ($leftX + 1 .. $rightX - 1)
                {
                    $grid->[$y][$fillX] = '~';
                }
            }
        }
    }
    else
    {
        return $x;
    }
}


flow(\@grid, $springX, $springY, 0);

# -------------------------------------------------
# Count water
# -------------------------------------------------

my $flowing = 0;
my $still   = 0;


for my $y ($minY .. $maxY)
{
    for my $x (0 .. $width - 1)
    {
        if ($grid[$y][$x] eq '|')
        {
            $flowing++;
        }
        elsif ($grid[$y][$x] eq '~')
        {
            $still++;
        }
    }
}


# -------------------------------------------------
# Output
# -------------------------------------------------

print "2018 day17: pl_ans_1: " . ($still + $flowing) . "\n";
print "2018 day17: pl_ans_2: $still\n";

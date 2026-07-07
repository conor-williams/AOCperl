#!/usr/bin/perl

use strict;
use warnings;

# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my @ground;

while (my $line = <$fh>)
{
    chomp $line;

    push @ground, [ split //, $line ];
}

close($fh);


my $height = scalar @ground;
my $width  = scalar @{$ground[0]};


# -------------------------------------------------
# Get neighbour
# -------------------------------------------------

sub get_cell
{
    my ($ground, $y, $x) = @_;


    return ' ' if $y < 0;
    return ' ' if $x < 0;
    return ' ' if $y >= @$ground;
    return ' ' if $x >= @{$ground->[$y]};


    return $ground->[$y][$x];
}


# -------------------------------------------------
# Count resources
# -------------------------------------------------

sub count_resources
{
    my ($snapshot) = @_;

    my $trees = () = $snapshot =~ /\|/g;
    my $yards = () = $snapshot =~ /\#/g;

    return $trees * $yards;
}


# -------------------------------------------------
# Simulation
# -------------------------------------------------

my @snapshots;


for my $g (1 .. 999)
{
    my @ground2;


    for my $y (0 .. $height - 1)
    {
        $ground2[$y] = [ @{$ground[$y]} ];
    }


    for my $y (0 .. $height - 1)
    {
        for my $x (0 .. $width - 1)
        {
            my $val = $ground[$y][$x];


            my @dirs =
            (
                [-1, -1],
                [-1,  0],
                [-1,  1],
                [ 0, -1],
                [ 0,  1],
                [ 1, -1],
                [ 1,  0],
                [ 1,  1],
            );


            my $neighbors = "";


            for my $dir (@dirs)
            {
                $neighbors .=
                    get_cell(
                        \@ground,
                        $y + $dir->[0],
                        $x + $dir->[1]
                    );
            }


            if ($val eq '.')
            {
                my $count = () = $neighbors =~ /\|/g;

                if ($count >= 3)
                {
                    $ground2[$y][$x] = '|';
                }
            }
            elsif ($val eq '|')
            {
                my $count = () = $neighbors =~ /\#/g;

                if ($count >= 3)
                {
                    $ground2[$y][$x] = '#';
                }
            }
            elsif ($val eq '#')
            {
                my $has_lumber =
                    $neighbors =~ /\#/;

                my $has_tree =
                    $neighbors =~ /\|/;


                if (!($has_lumber && $has_tree))
                {
                    $ground2[$y][$x] = '.';
                }
            }
        }
    }


    @ground = map { [@$_] } @ground2;


    my $snapshot = join(
        "\n",
        map { join('', @$_) } @ground
    );


    # ---------------------------------------------
    # Cycle detection
    # ---------------------------------------------

    my $found = -1;

    for my $i (0 .. $#snapshots)
    {
        if ($snapshots[$i] eq $snapshot)
        {
            $found = $i;
            last;
        }
    }


    if ($found != -1)
    {
        my $period = $g - (1 + $found);


        my $i = $found;


        while (($i + 1) % $period !=
               1000000000 % $period)
        {
            $i++;
        }


        print "2018 day18: pl_ans_2: ",
              count_resources($snapshots[$i]),
              "\n";

        last;
    }


    push @snapshots, $snapshot;


    # ---------------------------------------------
    # Part 1
    # ---------------------------------------------

    if ($g == 10)
    {
        print "2018 day18: pl_ans_1: ",
              count_resources($snapshot),
              "\n";
    }
}

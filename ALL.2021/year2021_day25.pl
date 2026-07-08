#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "usage: perl year2021_day25.pl input.txt\n";

open(my $fh, "<", $file) or die "$file: $!\n";

my @grid;

while (my $line = <$fh>) {
    chomp($line);
    $line =~ s/\r$//;

    next if $line eq "";

    push @grid, [ split(//, $line) ];
}

close($fh);

die "empty grid\n" unless scalar(@grid) > 0;
die "bad first row\n" unless defined $grid[0];


sub step {
    my ($grid) = @_;

    my $rows = scalar(@$grid);
    my $cols = scalar(@{$grid->[0]});

    my $moved = 0;

    #
    # East movement
    #
    my @east;

    for my $r (0 .. $rows-1) {
        $east[$r] = [ @{$grid->[$r]} ];
    }

    for my $r (0 .. $rows-1) {
        for my $c (0 .. $cols-1) {

            if ($grid->[$r][$c] eq '>') {

                my $nc = ($c + 1) % $cols;

                if ($grid->[$r][$nc] eq '.') {
                    $east[$r][$nc] = '>';
                    $east[$r][$c]  = '.';
                    $moved = 1;
                }
            }
        }
    }


    #
    # South movement
    #
    my @south;

    for my $r (0 .. $rows-1) {
        $south[$r] = [ @{$east[$r]} ];
    }


    for my $r (0 .. $rows-1) {
        for my $c (0 .. $cols-1) {

            if ($east[$r][$c] eq 'v') {

                my $nr = ($r + 1) % $rows;

                if ($east[$nr][$c] eq '.') {
                    $south[$nr][$c] = 'v';
                    $south[$r][$c]  = '.';
                    $moved = 1;
                }
            }
        }
    }


    return (\@south, $moved);
}


sub solve {
    my ($grid) = @_;

    my $count = 0;

    while (1) {
        my ($new_grid, $moved) = step($grid);

        $count++;

        $grid = $new_grid;

        last unless $moved;
    }

    return $count;
}


my $answer = solve(\@grid);

print "2021 day25: pl_ans_1: $answer\n";

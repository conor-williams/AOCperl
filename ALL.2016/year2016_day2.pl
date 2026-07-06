#!/usr/bin/env perl
use strict;
use warnings;

my @pad1 = (
    [qw(1 2 3)],
    [qw(4 5 6)],
    [qw(7 8 9)],
);

my @pad2 = (
    [qw(  1  )],
    [qw( 2 3 4 )],
    [qw(5 6 7 8 9)],
    [qw( A B C )],
    [qw(  D  )],
);

my $file = shift @ARGV;
open my $fh, '<', $file or die $!;

my @lines = <$fh>;

# ---------------- part 1 ----------------
my ($x, $y) = (1, 1);
my $ans1 = "";

for my $line (@lines) {
    chomp $line;

    for my $c (split //, $line) {
        my ($nx, $ny) = ($x, $y);

        $ny-- if $c eq 'U';
        $ny++ if $c eq 'D';
        $nx-- if $c eq 'L';
        $nx++ if $c eq 'R';

        if ($nx >= 0 && $nx < 3 && $ny >= 0 && $ny < 3) {
            ($x, $y) = ($nx, $ny);
        }
    }

    $ans1 .= $pad1[$y][$x];
}

# ---------------- part 2 ----------------
($x, $y) = (0, 2);
my $ans2 = "";

for my $line (@lines) {
    chomp $line;

    for my $c (split //, $line) {
        my ($nx, $ny) = ($x, $y);

        $ny-- if $c eq 'U';
        $ny++ if $c eq 'D';
        $nx-- if $c eq 'L';
        $nx++ if $c eq 'R';

        if ($nx >= 0 && $nx < 5 && $ny >= 0 && $ny < 5) {
            if (defined $pad2[$ny][$nx] && $pad2[$ny][$nx] ne ' ') {
                ($x, $y) = ($nx, $ny);
            }
        }
    }

    $ans2 .= $pad2[$y][$x];
}

print "2016 day2: pl_ans_1: $ans1\n";
my @pad2_2 = (
    [' ', ' ', '1', ' ', ' '],
    [' ', '2', '3', '4', ' '],
    ['5', '6', '7', '8', '9'],
    [' ', 'A', 'B', 'C', ' '],
    [' ', ' ', 'D', ' ', ' ']
);

my $x2 = 0;
my $y2 = 2;
my $ans2_2 = "";

for my $line (@lines) {
    for my $c (split //, $line) {

        my ($nx, $ny) = ($x2, $y2);

        if ($c eq 'U') { $ny--; }
        elsif ($c eq 'D') { $ny++; }
        elsif ($c eq 'L') { $nx--; }
        elsif ($c eq 'R') { $nx++; }

        # IMPORTANT: must match Python exactly
        if ($nx >= 0 && $nx < 5 && $ny >= 0 && $ny < 5 && $pad2_2[$ny][$nx] ne ' ') {
            $x2 = $nx;
            $y2 = $ny;
        }
    }

    $ans2_2 .= $pad2_2[$y2][$x2];
}

print "2016 day2: pl_ans_2: $ans2_2\n";

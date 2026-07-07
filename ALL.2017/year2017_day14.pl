#!/usr/bin/perl
use strict;
use warnings;

open(my $fh, "<", $ARGV[0]) or die "Cannot open file\n";

my $KEY = <$fh>;
chomp($KEY);

close($fh);


# ============================================================
# Knot hash (AoC 2017 Day 10)
# ============================================================

sub knot_hash {

    my ($s) = @_;

    my @nums = (0..255);

    my @lengths;

    foreach my $c (split //, $s) {
        push @lengths, ord($c);
    }

    push @lengths, (17,31,73,47,23);


    my $pos = 0;
    my $skip = 0;


    for (my $r = 0; $r < 64; $r++) {

        foreach my $length (@lengths) {

            my @tmp;

            for (my $i = 0; $i < $length; $i++) {
                push @tmp, $nums[($pos+$i) % 256];
            }


            @tmp = reverse @tmp;


            for (my $i = 0; $i < $length; $i++) {
                $nums[($pos+$i) % 256] = $tmp[$i];
            }


            $pos = ($pos + $length + $skip) % 256;
            $skip++;
        }
    }


    my @dense;


    for (my $i = 0; $i < 16; $i++) {

        my $x = $nums[$i*16];

        for (my $j = 1; $j < 16; $j++) {
            $x ^= $nums[$i*16+$j];
        }

        push @dense, $x;
    }


    my $out = "";

    foreach my $x (@dense) {
        $out .= sprintf("%02x", $x);
    }

    return $out;
}


# ============================================================
# Build grid
# ============================================================

my @grid;


for (my $i = 0; $i < 128; $i++) {

    my $h = knot_hash("$KEY-$i");

    my $bits = "";

    foreach my $c (split //, $h) {

        $bits .= sprintf("%04b", hex($c));
    }

    push @grid, [ split //, $bits ];
}


# ============================================================
# Part 1
# ============================================================

my $part1 = 0;


foreach my $row (@grid) {

    foreach my $c (@$row) {

        if ($c eq "1") {
            $part1++;
        }
    }
}


print "2017 day14: pl_ans_1: $part1\n";


# ============================================================
# Part 2
# ============================================================

my %seen;

my $regions = 0;

my @DY = (-1,0,1,0);
my @DX = (0,1,0,-1);


sub dfs {

    my ($y,$x) = @_;

    my @stack;

    push @stack, [$y,$x];


    while (@stack) {

        my $p = pop @stack;

        my ($cy,$cx) = @$p;


        next if exists $seen{"$cy,$cx"};

        $seen{"$cy,$cx"} = 1;


        for (my $d=0; $d<4; $d++) {

            my $ny = $cy + $DY[$d];
            my $nx = $cx + $DX[$d];


            next if $ny < 0 || $ny >= 128;
            next if $nx < 0 || $nx >= 128;


            next if $grid[$ny][$nx] ne "1";


            push @stack, [$ny,$nx];
        }
    }
}


for (my $y=0; $y<128; $y++) {

    for (my $x=0; $x<128; $x++) {

        next if $grid[$y][$x] ne "1";

        next if exists $seen{"$y,$x"};


        $regions++;

        dfs($y,$x);
    }
}


print "2017 day14: pl_ans_2: $regions\n";

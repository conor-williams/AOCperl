#!/usr/bin/env perl

use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$file: $!";

local $/;
my $input = <$fh>;

close $fh;



sub parse_schematic {

    my ($block)=@_;


    my @grid =
        map { [split //] }
        split /\n/, $block;


    my $h=@grid;
    my $w=@{$grid[0]};


    my @heights;


    for my $x (0..$w-1) {

        my $count=0;


        for my $y (0..$h-1) {

            if ($grid[$y][$x] eq "#") {
                $count++;
            }
        }


        push @heights,$count;
    }


    return \@heights;
}



my @blocks =
    grep { /\S/ }
    split /\n\n/, $input;


my @locks;
my @keys;



for my $block (@blocks) {


    my @lines =
        split /\n/, $block;


    if ($lines[0] =~ /^#+$/) {

        push @locks, parse_schematic($block);

    }
    else {

        push @keys, parse_schematic($block);
    }
}



# ============================================================
# Part 1
# ============================================================

my $p1=0;


for my $lock (@locks) {

    for my $key (@keys) {


        my $ok=1;


        for my $i (0..$#$lock) {

            # 7 is the total height of the schematic
            # lock + key cannot overlap

            if ($lock->[$i] + $key->[$i] > 7) {

                $ok=0;
                last;
            }
        }


        $p1++ if $ok;
    }
}



print "2024 day25: pl_ans_1: $p1\n";
print "2024 day25: pl_ans_2: Merry Christmas!\n";

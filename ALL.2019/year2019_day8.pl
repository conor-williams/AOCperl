#!/usr/bin/perl

use strict;
use warnings;

use constant W => 25;
use constant H => 6;

sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die $!;

    my $data = '';

    while (<$fh>) {
        chomp;
        $data .= $_;
    }

    close $fh;

    my $size = W * H;

    my @layers;

    for (my $i = 0; $i < length($data); $i += $size) {

        push @layers,
            substr($data, $i, $size);
    }

    # -------------------------
    # Part 1
    # -------------------------

    my $best = $layers[0];

    for my $layer (@layers) {

        my $zeros = ($layer =~ tr/0/0/);

        my $bestzeros = ($best =~ tr/0/0/);

        if ($zeros < $bestzeros) {

            $best = $layer;
        }
    }

    my $ones = ($best =~ tr/1/1/);
    my $twos = ($best =~ tr/2/2/);

    my $p1 = $ones * $twos;

    # -------------------------
    # Part 2
    # -------------------------

    my @image = ("2") x $size;

    for my $layer (@layers) {

        for my $i (0 .. $size-1) {

            my $c = substr($layer,$i,1);

            if ($image[$i] eq "2"
                && $c ne "2") {

                $image[$i] = $c;
            }
        }
    }

    print "2019 day8: pl_ans_1: $p1\n";
    print "2019 day8: pl_ans_2:\n";

    for my $y (0 .. H-1) {

        for my $x (0 .. W-1) {

            my $c =
                $image[$y*W+$x];

            print $c eq "1"
                ? "#"
                : " ";
        }

        print "\n";
    }
}

main();

#!/usr/bin/perl

use strict;
use warnings;

sub knot_round {
    my ($lengths, $lst, $pos, $skip) = @_;

    $pos = 0 unless defined $pos;
    $skip = 0 unless defined $skip;

    my $n = scalar(@$lst);

    foreach my $length (@$lengths) {

        # reverse section
        for (my $i = 0; $i < int($length / 2); $i++) {

            my $a = ($pos + $i) % $n;
            my $b = ($pos + $length - 1 - $i) % $n;

            ($lst->[$a], $lst->[$b]) = ($lst->[$b], $lst->[$a]);
        }

        $pos = ($pos + $length + $skip) % $n;
        $skip++;
    }

    return ($pos, $skip);
}

sub knot_hash {
    my ($s) = @_;

    my @lengths = map { ord($_) } split //, $s;
    push @lengths, (17,31,73,47,23);

    my @lst = (0 .. 255);

    my $pos = 0;
    my $skip = 0;

    for (1 .. 64) {
        ($pos, $skip) = knot_round(\@lengths, \@lst, $pos, $skip);
    }

    my @dense;

    for (my $i = 0; $i < 256; $i += 16) {

        my $x = $lst[$i];

        for (my $j = 1; $j < 16; $j++) {
            $x ^= $lst[$i + $j];
        }

        push @dense, $x;
    }

    return join("", map { sprintf("%02x", $_) } @dense);
}

my $file = $ARGV[0];

open(my $fh, "<", $file) or die;
my $s = <$fh>;
close($fh);

chomp $s;

# Part 1

my @lengths = map { int($_) } split(/,/, $s);

my @lst = (0 .. 255);

knot_round(\@lengths, \@lst);

my $p1 = $lst[0] * $lst[1];

# Part 2

my $p2 = knot_hash($s);

print "2017 day10: pl_ans_1: $p1\n";
print "2017 day10: pl_ans_2: $p2\n";

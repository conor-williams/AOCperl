#!/usr/bin/perl
use strict;
use warnings;

sub extrapolate {
    my (@seq) = @_;

    my @layers = (\@seq);

    while (1) {
        my $all_zero = 1;

        for my $x (@{ $layers[-1] }) {
            if ($x != 0) {
                $all_zero = 0;
                last;
            }
        }

        last if $all_zero;

        my @prev = @{ $layers[-1] };
        my @next;

        for my $i (0 .. $#prev - 1) {
            push @next, $prev[$i + 1] - $prev[$i];
        }

        push @layers, \@next;
    }

    # Part 1: extend forward
    my $nxt = 0;

    for my $layer (reverse @layers) {
        $nxt += $layer->[-1];
    }

    # Part 2: extend backward
    my $prev = 0;

    for my $layer (reverse @layers) {
        $prev = $layer->[0] - $prev;
    }

    return ($nxt, $prev);
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @lines;

    while (<$fh>) {
        chomp;

        if (/\S/) {
            push @lines, [split /\s+/];
        }
    }

    close $fh;

    my $p1 = 0;
    my $p2 = 0;

    for my $line (@lines) {
        my @seq = map { int($_) } @$line;

        my ($a, $b) = extrapolate(@seq);

        $p1 += $a;
        $p2 += $b;
    }

    print "2023 day9: pl_ans_1: $p1\n";
    print "2023 day9: pl_ans_2: $p2\n";
}

main();

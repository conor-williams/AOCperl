#!/usr/bin/perl

use strict;
use warnings;

sub fuel {
    my ($m) = @_;
    return int($m / 3) - 2;
}

sub fuel_recursive {
    my ($m) = @_;

    my $total = 0;

    while (1) {
        $m = fuel($m);

        last if $m <= 0;

        $total += $m;
    }

    return $total;
}

sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die "Cannot open '$path': $!";

    my @masses;

    while (my $line = <$fh>) {
        chomp $line;

        next unless $line =~ /\S/;

        push @masses, int($line);
    }

    close $fh;

    # Part 1
    my $p1 = 0;
    $p1 += fuel($_) for @masses;

    # Part 2
    my $p2 = 0;
    $p2 += fuel_recursive($_) for @masses;

    print "2019 day1: pl_ans_1: $p1\n";
    print "2019 day1: pl_ans_2: $p2\n";
}

main() unless caller();

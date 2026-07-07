#!/usr/bin/perl

use strict;
use warnings;

sub is_valid_part1 {
    my ($words) = @_;

    my %seen;

    foreach my $w (@$words) {
        return 0 if exists $seen{$w};
        $seen{$w} = 1;
    }

    return 1;
}

sub is_valid_part2 {
    my ($words) = @_;

    my %seen;

    foreach my $w (@$words) {

        my $sig = join("", sort split(//, $w));

        if (exists $seen{$sig}) {
            return 0;
        }

        $seen{$sig} = 1;
    }

    return 1;
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq "";
        push @lines, $line;
    }

    close($fh);

    my $p1 = 0;
    my $p2 = 0;

    foreach my $line (@lines) {

        my @words = split(/\s+/, $line);

        if (is_valid_part1(\@words)) {
            $p1++;
        }

        if (is_valid_part2(\@words)) {
            $p2++;
        }
    }

    print "2017 day4: pl_ans_1: $p1\n";
    print "2017 day4: pl_ans_2: $p2\n";
}

main();

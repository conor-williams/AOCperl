#!/usr/bin/env perl

use strict;
use warnings;

sub is_nice_part1 {
    my ($s) = @_;

    # at least 3 vowels
    my $count = () = ($s =~ /[aeiou]/g);
    return 0 if $count < 3;

    # at least one letter twice in a row
    return 0 unless $s =~ /(.)\1/;

    # no forbidden substrings
    return 0 if $s =~ /(ab|cd|pq|xy)/;

    return 1;
}

sub is_nice_part2 {
    my ($s) = @_;

    # pair appears at least twice without overlapping
    return 0 unless $s =~ /(..).*\1/;

    # letter repeats with exactly one between
    return 0 unless $s =~ /(.).\1/;

    return 1;
}

sub main {

    open my $fh, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!";

    my @lines;

    while (<$fh>) {
        chomp;
        push @lines, $_;
    }

    close $fh;

    my $p1 = 0;
    my $p2 = 0;

    foreach my $s (@lines) {
        $p1++ if is_nice_part1($s);
        $p2++ if is_nice_part2($s);
    }

    print "2015 day5: pl_ans_1: $p1\n";
    print "2015 day5: pl_ans_2: $p2\n";
}

main();

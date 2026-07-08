#!/usr/bin/perl
use strict;
use warnings;

sub extract_digits {
    my ($line) = @_;

    my @digits = ($line =~ /(\d)/g);

    return int($digits[0] . $digits[-1]);
}

sub replace_words {
    my ($line) = @_;

    # Keep overlaps (important)
    my %mapping = (
        "one"   => "o1e",
        "two"   => "t2o",
        "three" => "t3e",
        "four"  => "f4r",
        "five"  => "f5e",
        "six"   => "s6x",
        "seven" => "s7n",
        "eight" => "e8t",
        "nine"  => "n9e",
    );

    for my $k (keys %mapping) {
        $line =~ s/\Q$k\E/$mapping{$k}/g;
    }

    return $line;
}

sub main {
    my ($path) = @ARGV;

    open my $fh, "<", $path or die "Cannot open $path: $!";

    my @lines;
    while (<$fh>) {
        chomp;
        push @lines, $_ if $_ ne "";
    }
    close $fh;

    # Part 1
    my $p1 = 0;
    for my $line (@lines) {
        $p1 += extract_digits($line);
    }

    # Part 2
    my $p2 = 0;
    for my $line (@lines) {
        my $converted = replace_words($line);
        $p2 += extract_digits($converted);
    }

    print "2023 day1: pl_ans_1: $p1\n";
    print "2023 day1: pl_ans_2: $p2\n";
}

main();

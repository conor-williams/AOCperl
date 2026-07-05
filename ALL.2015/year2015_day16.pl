#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(all);

my %TARGET = (
    children    => 3,
    cats        => 7,
    samoyeds    => 2,
    pomeranians => 3,
    akitas      => 0,
    vizslas     => 0,
    goldfish    => 5,
    trees       => 3,
    cars        => 2,
    perfumes    => 1,
);

sub parse {
    my ($lines) = @_;

    my @sues;

    foreach my $line (@$lines) {

        my %props = ($line =~ /(\w+): (\d+)/g);

        my %h = map { $_ => 0 + $props{$_} } keys %props;

        push @sues, \%h;
    }

    return \@sues;
}

sub match_part1 {
    my ($sue) = @_;

    for my $k (keys %$sue) {
        return 0 if $TARGET{$k} != $sue->{$k};
    }

    return 1;
}

sub match_part2 {
    my ($sue) = @_;

    for my $k (keys %$sue) {

        my $v = $sue->{$k};

        if ($k eq "cats" || $k eq "trees") {
            return 0 if $v <= $TARGET{$k};
        }
        elsif ($k eq "pomeranians" || $k eq "goldfish") {
            return 0 if $v >= $TARGET{$k};
        }
        else {
            return 0 if $v != $TARGET{$k};
        }
    }

    return 1;
}

sub solve {
    my ($lines) = @_;

    my $sues = parse($lines);

    my ($p1, $p2);

    for my $i (0 .. $#$sues) {

        my $sue = $sues->[$i];

        if (!defined $p1 && match_part1($sue)) {
            $p1 = $i + 1;
        }

        if (!defined $p2 && match_part2($sue)) {
            $p2 = $i + 1;
        }
    }

    return ($p1, $p2);
}

sub main {
    open my $fh, '<', $ARGV[0] or die $!;
    my @lines = grep { length } map { chomp; $_ } <$fh>;
    close $fh;

    my ($p1, $p2) = solve(\@lines);

    print "2015 day16: pl_ans_1: $p1\n";
    print "2015 day16: pl_ans_2: $p2\n";
}

main();

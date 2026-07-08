#!/usr/bin/perl
use strict;
use warnings;

sub main {

    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @lines;
    while (<$fh>) {
        chomp;
        push @lines, $_ if /\S/;
    }

    close $fh;

    my @scores;
    my @matches;

    for my $line (@lines) {

        my ($data) = $line =~ /:(.*)/;

        my ($left, $right) = split /\|/, $data;

        my %winning;

        for my $n (split /\s+/, $left) {
            $winning{$n} = 1 if $n ne "";
        }

        my @have = grep { $_ ne "" } split /\s+/, $right;

        my $m = 0;

        for my $x (@have) {
            $m++ if exists $winning{$x};
        }

        push @matches, $m;

        if ($m == 0) {
            push @scores, 0;
        } else {
            push @scores, 2 ** ($m - 1);
        }
    }

    my $p1 = 0;
    $p1 += $_ for @scores;

    my @copies = (1) x scalar(@lines);

    for my $i (0 .. $#matches) {
        my $m = $matches[$i];

        for my $j (1 .. $m) {
            if ($i + $j < scalar(@lines)) {
                $copies[$i + $j] += $copies[$i];
            }
        }
    }

    my $p2 = 0;
    $p2 += $_ for @copies;

    print "2023 day4: pl_ans_1: $p1\n";
    print "2023 day4: pl_ans_2: $p2\n";
}

main();

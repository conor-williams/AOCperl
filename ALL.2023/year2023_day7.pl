#!/usr/bin/perl
use strict;
use warnings;

sub hand_type {
    my ($hand, $part2) = @_;

    my %c;

    for my $card (split //, $hand) {
        $c{$card}++;
    }

    if ($part2 && exists $c{"J"} && keys(%c) > 1) {
        my $j = delete $c{"J"};

        my $best;
        my $max = 0;

        for my $k (keys %c) {
            if ($c{$k} > $max) {
                $max = $c{$k};
                $best = $k;
            }
        }

        $c{$best} += $j if defined $best;
    }

    my @counts = sort { $b <=> $a } values %c;

    return 7 if @counts == 1 && $counts[0] == 5;
    return 6 if @counts == 2 && $counts[0] == 4 && $counts[1] == 1;
    return 5 if @counts == 2 && $counts[0] == 3 && $counts[1] == 2;
    return 4 if @counts == 3 && $counts[0] == 3;
    return 3 if @counts == 3 && $counts[0] == 2 && $counts[1] == 2;
    return 2 if @counts == 4 && $counts[0] == 2;

    return 1;
}

sub strength {
    my ($card, $part2) = @_;

    my $order1 = "23456789TJQKA";
    my $order2 = "J23456789TQKA";

    return index($part2 ? $order2 : $order1, $card);
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @lines;
    while (<$fh>) {
        chomp;
        push @lines, [split /\s+/] if /\S/;
    }

    close $fh;

    sub solve {
        my ($lines_ref, $part2) = @_;

        my @hands;

        for my $line (@$lines_ref) {
            my ($hand, $bid) = @$line;

            my $type = hand_type($hand, $part2);

            my @strengths;
            push @strengths, strength($_, $part2) for split //, $hand;

            push @hands, [
                $type,
                \@strengths,
                int($bid)
            ];
        }

        @hands = sort {
            $a->[0] <=> $b->[0]
            ||
            compare_arrays($a->[1], $b->[1])
        } @hands;

        my $sum = 0;

        for my $i (0 .. $#hands) {
            $sum += ($i + 1) * $hands[$i]->[2];
        }

        return $sum;
    }

    my $p1 = solve(\@lines, 0);
    my $p2 = solve(\@lines, 1);

    print "2023 day7: pl_ans_1: $p1\n";
    print "2023 day7: pl_ans_2: $p2\n";
}

sub compare_arrays {
    my ($a, $b) = @_;

    for my $i (0 .. $#$a) {
        return $a->[$i] <=> $b->[$i]
            if $a->[$i] != $b->[$i];
    }

    return 0;
}

main();

#!/usr/bin/perl
use strict;
use warnings;

sub compare {
    my ($left, $right) = @_;

    # both integers
    if (!ref($left) && !ref($right)) {
        return ($left > $right) - ($left < $right);
    }

    # int -> list
    if (!ref($left)) {
        $left = [$left];
    }

    if (!ref($right)) {
        $right = [$right];
    }

    my $len = @$left < @$right ? @$left : @$right;

    for my $i (0 .. $len - 1) {
        my $res = compare($left->[$i], $right->[$i]);

        return $res if $res != 0;
    }

    return (@$left > @$right) - (@$left < @$right);
}

sub parse_value {
    my ($s) = @_;

    # Recursive parser for Python-style nested lists
    my @tokens = ($s =~ /[\[\],]|\d+/g);
    my $pos = 0;

    return parse_list(\@tokens, \$pos);
}

sub parse_list {
    my ($tokens, $pos) = @_;

    my @list;

    $$pos++; # skip [

    while ($$pos < @$tokens && $tokens->[$$pos] ne "]") {

        if ($tokens->[$$pos] eq ",") {
            $$pos++;
            next;
        }

        if ($tokens->[$$pos] eq "[") {
            push @list, parse_list($tokens, $pos);
        }
        else {
            push @list, int($tokens->[$$pos]);
            $$pos++;
        }
    }

    $$pos++; # skip ]

    return \@list;
}

sub part1 {
    my ($pairs) = @_;

    my $total = 0;

    for my $i (0 .. $#$pairs) {
        my ($a, $b) = @{ $pairs->[$i] };

        if (compare($a, $b) < 0) {
            $total += $i + 1;
        }
    }

    return $total;
}

sub part2 {
    my ($packets) = @_;

    my $div1 = [[2]];
    my $div2 = [[6]];

    push @$packets, $div1;
    push @$packets, $div2;

    @$packets = sort {
        compare($a, $b)
    } @$packets;

    my ($i1, $i2);

    for my $i (0 .. $#$packets) {
        $i1 = $i + 1 if $packets->[$i] == $div1;
        $i2 = $i + 1 if $packets->[$i] == $div2;
    }

    return $i1 * $i2;
}

sub parse {
    my (@lines) = @_;

    my @pairs;
    my @packets;
    my @cur;

    for my $line (@lines) {
        $line =~ s/^\s+|\s+$//g;

        if ($line eq "") {
            if (@cur == 2) {
                push @pairs, [@cur];
                push @packets, @cur;
            }

            @cur = ();
        }
        else {
            push @cur, parse_value($line);
        }
    }

    if (@cur == 2) {
        push @pairs, [@cur];
        push @packets, @cur;
    }

    return (\@pairs, \@packets);
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @lines = <$fh>;

    close $fh;

    chomp @lines;

    my ($pairs, $packets) = parse(@lines);

    my $p1 = part1($pairs);
    my $p2 = part2($packets);

    print "2023 day13: pl_ans_1: $p1\n";
    print "2023 day13: pl_ans_2: $p2\n";
}

main();

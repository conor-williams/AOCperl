#!/usr/bin/perl
use strict;
use warnings;
no warnings 'recursion';

my %memo;

sub dp {
    my ($pattern, $groups, $i, $gi, $run) = @_;

    my $key = "$i,$gi,$run";
    return $memo{$key} if exists $memo{$key};

    my $n = length($pattern);

    if ($i == $n) {
        if ($gi == @$groups && $run == 0) {
            return $memo{$key} = 1;
        }

        if ($gi == @$groups - 1 &&
            $run == $groups->[$gi]) {
            return $memo{$key} = 1;
        }

        return $memo{$key} = 0;
    }

    my $res = 0;
    my $c = substr($pattern, $i, 1);

    if ($c eq "." || $c eq "?") {
        if ($run > 0) {
            if ($gi < @$groups &&
                $run == $groups->[$gi]) {
                $res += dp($pattern, $groups, $i + 1, $gi + 1, 0);
            }
        }
        else {
            $res += dp($pattern, $groups, $i + 1, $gi, 0);
        }
    }

    if ($c eq "#" || $c eq "?") {
        $res += dp($pattern, $groups, $i + 1, $gi, $run + 1);
    }

    return $memo{$key} = $res;
}

sub solve {
    my ($pattern, $groups) = @_;

    %memo = ();

    return dp($pattern, $groups, 0, 0, 0);
}

sub unfold {
    my ($pattern, $groups) = @_;

    my $p = join("?", ($pattern) x 5);

    my @g = (@$groups, @$groups, @$groups, @$groups, @$groups);

    return ($p, \@g);
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @rows;

    while (<$fh>) {
        chomp;

        next unless /\S/;

        my ($s, $nums) = split /\s+/;

        my @groups = map { int($_) } split /,/, $nums;

        push @rows, [$s, \@groups];
    }

    close $fh;

    my $p1 = 0;
    my $p2 = 0;

    for my $row (@rows) {
        my ($pattern, $groups) = @$row;

        $p1 += solve($pattern, $groups);

        my ($up, $ug) = unfold($pattern, $groups);

        $p2 += solve($up, $ug);
    }

    print "2023 day12: pl_ans_1: $p1\n";
    print "2023 day12: pl_ans_2: $p2\n";
}

main();

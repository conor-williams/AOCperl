#!/usr/bin/perl
use strict;
use warnings;

sub solve {
    my (@instructions) = @_;

    my ($x, $y) = (0, 0);

    my @points = ([0,0]);

    my $perimeter = 0;

    for my $ins (@instructions) {
        my ($d, $n) = @$ins;

        $n = int($n);

        if ($d eq "U") {
            $y -= $n;
        }
        elsif ($d eq "D") {
            $y += $n;
        }
        elsif ($d eq "L") {
            $x -= $n;
        }
        elsif ($d eq "R") {
            $x += $n;
        }

        push @points, [$x,$y];

        $perimeter += $n;
    }

    my $area = 0;

    for my $i (0 .. $#points-1) {
        my ($x1,$y1)=@{ $points[$i] };
        my ($x2,$y2)=@{ $points[$i+1] };

        $area += $x1*$y2 - $x2*$y1;
    }

    $area = abs($area) / 2;

    return $area + int($perimeter / 2) + 1;
}

sub parse1 {
    my (@lines)=@_;

    my @out;

    for my $line (@lines) {
        my ($d,$n,$dummy)=split /\s+/, $line;
        push @out, [$d,$n];
    }

    return @out;
}

sub parse2 {
    my (@lines)=@_;

    my @out;

    for my $line (@lines) {
        my ($hexcode) = $line =~ /#([0-9a-f]+)/;

        my $n = hex(substr($hexcode,0,5));

        my $dcode = substr($hexcode,5,1);

        my $d;

        if ($dcode eq "0") {
            $d="R";
        }
        elsif ($dcode eq "1") {
            $d="D";
        }
        elsif ($dcode eq "2") {
            $d="L";
        }
        else {
            $d="U";
        }

        push @out, [$d,$n];
    }

    return @out;
}

sub main {
    my $path=$ARGV[0];

    open my $fh,"<",$path or die "$path: $!";

    my @lines=<$fh>;

    close $fh;

    chomp @lines;

    @lines = grep { /\S/ } @lines;

    my $p1=solve(parse1(@lines));
    my $p2=solve(parse2(@lines));

    print "2023 day18: pl_ans_1: $p1\n";
    print "2023 day18: pl_ans_2: $p2\n";
}

main();

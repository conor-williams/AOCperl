#!/usr/bin/perl
use strict;
use warnings;

sub step {
    my ($x, $y, $dx, $dy, $grid) = @_;

    my $c = substr($grid->[$y], $x, 1);

    if ($c eq ".") {
        return ([$x+$dx, $y+$dy, $dx, $dy]);
    }

    if ($c eq "/") {
        return ([$x-$dy, $y-$dx, -$dy, -$dx]);
    }

    if ($c eq "\\") {
        return ([$x+$dy, $y+$dx, $dy, $dx]);
    }

    if ($c eq "|") {
        if ($dx != 0) {
            return (
                [$x, $y-1, 0, -1],
                [$x, $y+1, 0, 1]
            );
        }
        else {
            return ([$x+$dx, $y+$dy, $dx, $dy]);
        }
    }

    if ($c eq "-") {
        if ($dy != 0) {
            return (
                [$x-1, $y, -1, 0],
                [$x+1, $y, 1, 0]
            );
        }
        else {
            return ([$x+$dx, $y+$dy, $dx, $dy]);
        }
    }

    return ();
}

sub energize {
    my ($grid, $start) = @_;

    my $h = scalar @$grid;
    my $w = length($grid->[0]);

    my @q = ($start);
    my %seen;
    my %energized;

    my $head = 0;

    while ($head < @q) {

        my ($x,$y,$dx,$dy) = @{ $q[$head++] };

        my $key = "$x,$y,$dx,$dy";

        next if exists $seen{$key};

        $seen{$key} = 1;

        next if $x < 0 || $x >= $w || $y < 0 || $y >= $h;

        $energized{"$x,$y"} = 1;

        for my $n (step($x,$y,$dx,$dy,$grid)) {
            my ($nx,$ny,$ndx,$ndy)=@$n;

            if ($nx >= 0 && $nx < $w &&
                $ny >= 0 && $ny < $h) {
                push @q, [$nx,$ny,$ndx,$ndy];
            }
        }
    }

    return scalar keys %energized;
}

sub solve {
    my ($text) = @_;

    my @grid = split /\n/, $text;

    my $p1 = energize(\@grid, [0,0,1,0]);

    my $h = scalar @grid;
    my $w = length($grid[0]);

    my $best = 0;

    for my $x (0 .. $w-1) {
        $best = energize(\@grid, [$x,0,0,1])
            if energize(\@grid, [$x,0,0,1]) > $best;

        $best = energize(\@grid, [$x,$h-1,0,-1])
            if energize(\@grid, [$x,$h-1,0,-1]) > $best;
    }

    for my $y (0 .. $h-1) {
        $best = energize(\@grid, [0,$y,1,0])
            if energize(\@grid, [0,$y,1,0]) > $best;

        $best = energize(\@grid, [$w-1,$y,-1,0])
            if energize(\@grid, [$w-1,$y,-1,0]) > $best;
    }

    return ($p1,$best);
}

sub main {
    my $path = $ARGV[0];

    open my $fh,"<",$path or die "$path: $!";

    local $/;
    my $text = <$fh>;

    close $fh;

    my ($p1,$p2)=solve($text);

    print "2023 day16: pl_ans_1: $p1\n";
    print "2023 day16: pl_ans_2: $p2\n";
}

main();

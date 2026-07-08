#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

open(my $fh, "<", $file) or die $!;

my @grid;
while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @grid, [ split // ];
}
close($fh);

my $h = scalar @grid;
my $w = scalar @{$grid[0]};

my ($sx,$sy,$ex,$ey);

for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        if ($grid[$y][$x] eq "S") {
            ($sx,$sy)=($x,$y);
            $grid[$y][$x]="a";
        }

        if ($grid[$y][$x] eq "E") {
            ($ex,$ey)=($x,$y);
            $grid[$y][$x]="z";
        }
    }
}

sub bfs {

    my ($starts,$endx,$endy)=@_;

    my @dist;

    for my $y (0..$h-1){
        for my $x (0..$w-1){
            $dist[$y][$x]=1_000_000_000;
        }
    }

    my @qx;
    my @qy;
    my $head=0;

    foreach my $p (@$starts){
        push @qx,$p->[0];
        push @qy,$p->[1];
        $dist[$p->[1]][$p->[0]]=0;
    }

    while($head<@qx){

        my $x=$qx[$head];
        my $y=$qy[$head];
        $head++;

        return $dist[$y][$x]
            if $x==$endx && $y==$endy;

        foreach my $d (
            [1,0],[-1,0],[0,1],[0,-1]
        ){

            my $nx=$x+$d->[0];
            my $ny=$y+$d->[1];

            next if $nx<0 || $ny<0 || $nx>=$w || $ny>=$h;

            next if ord($grid[$ny][$nx]) - ord($grid[$y][$x]) > 1;

            if($dist[$ny][$nx] > $dist[$y][$x]+1){

                $dist[$ny][$nx]=$dist[$y][$x]+1;

                push @qx,$nx;
                push @qy,$ny;
            }
        }
    }

    return undef;
}

my $p1 = bfs([[ $sx,$sy ]],$ex,$ey);

my @starts;

for my $y (0..$h-1){
    for my $x (0..$w-1){
        push @starts,[$x,$y]
            if $grid[$y][$x] eq "a";
    }
}

my $p2 = bfs(\@starts,$ex,$ey);

print "2022 day12: pl_ans_1: $p1\n";
print "2022 day12: pl_ans_2: $p2\n";

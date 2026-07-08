#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;
my @lines = <$fh>;
close($fh);

chomp @lines;

my %rocks;

foreach my $line (@lines) {
    next if $line eq "";

    my @pts = split / -> /, $line;

    for (my $i = 0; $i < @pts-1; $i++) {

        my ($x1,$y1)=split /,/,$pts[$i];
        my ($x2,$y2)=split /,/,$pts[$i+1];

        my $xmin = $x1<$x2 ? $x1 : $x2;
        my $xmax = $x1>$x2 ? $x1 : $x2;
        my $ymin = $y1<$y2 ? $y1 : $y2;
        my $ymax = $y1>$y2 ? $y1 : $y2;

        for my $x ($xmin..$xmax) {
            for my $y ($ymin..$ymax) {
                $rocks{"$x,$y"} = 1;
            }
        }
    }
}

my $max_y = 0;
foreach my $k (keys %rocks) {
    my (undef,$y)=split /,/,$k;
    $max_y = $y if $y > $max_y;
}

my ($x,$y)=(500,0);

my $count=0;
my $p1=0;
my $p2=0;

while (1) {

    if (exists $rocks{"$x,$y"}) {
        ($x,$y)=(500,0);
    }

    if ($y>$max_y && !$p1) {
        $p1=$count;
    }

    if (!exists($rocks{($x).",".($y+1)}) && $y<$max_y+1) {

        $y++;

    } elsif (!exists($rocks{($x-1).",".($y+1)}) && $y<$max_y+1) {

        $x--;
        $y++;

    } elsif (!exists($rocks{($x+1).",".($y+1)}) && $y<$max_y+1) {

        $x++;
        $y++;

    } else {

        $count++;
        $rocks{"$x,$y"}=1;

    }

    if ($x==500 && $y==0) {
        $p2=$count;
        last;
    }
}

print "2022 day14: pl_ans_1: $p1\n";
print "2022 day14: pl_ans_2: $p2\n";

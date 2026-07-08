#!/usr/bin/perl
use strict;
use warnings;


my $file = $ARGV[0];

open(my $fh, "<", $file) or die $!;

my %cubes;

while(<$fh>) {
    chomp;
    next if $_ eq "";

    my ($x,$y,$z)=split(/,/);

    $cubes{"$x,$y,$z"}=1;
}

close($fh);



sub neighbors {

    my ($x,$y,$z)=@_;

    return (
        [$x+1,$y,$z],
        [$x-1,$y,$z],
        [$x,$y+1,$z],
        [$x,$y-1,$z],
        [$x,$y,$z+1],
        [$x,$y,$z-1]
    );
}



my ($minx,$maxx,$miny,$maxy,$minz,$maxz);

foreach my $key (keys %cubes) {

    my ($x,$y,$z)=split(/,/,$key);

    $minx=$x if !defined($minx) || $x<$minx;
    $maxx=$x if !defined($maxx) || $x>$maxx;

    $miny=$y if !defined($miny) || $y<$miny;
    $maxy=$y if !defined($maxy) || $y>$maxy;

    $minz=$z if !defined($minz) || $z<$minz;
    $maxz=$z if !defined($maxz) || $z>$maxz;
}


$minx--;
$maxx++;
$miny--;
$maxy++;
$minz--;
$maxz++;



# -------------------------
# Part 1
# -------------------------

my $p1=0;


foreach my $key (keys %cubes) {

    my ($x,$y,$z)=split(/,/,$key);

    foreach my $n (neighbors($x,$y,$z)) {

        my $k=join(",",@$n);

        $p1++ unless exists $cubes{$k};
    }
}



# -------------------------
# Part 2 flood fill outside
# -------------------------

my $start="$minx,$miny,$minz";


my @queue=($start);

my %seen;
$seen{$start}=1;


my %outside;


while(@queue) {

    my $cur=shift @queue;

    my ($x,$y,$z)=split(/,/,$cur);


    foreach my $n (neighbors($x,$y,$z)) {

        my ($nx,$ny,$nz)=@$n;


        next if $nx<$minx || $nx>$maxx;
        next if $ny<$miny || $ny>$maxy;
        next if $nz<$minz || $nz>$maxz;


        my $k="$nx,$ny,$nz";


        next if exists $cubes{$k};
        next if exists $seen{$k};


        $seen{$k}=1;
        $outside{$k}=1;

        push @queue,$k;
    }
}



my $p2=0;


foreach my $key (keys %cubes) {

    my ($x,$y,$z)=split(/,/,$key);


    foreach my $n (neighbors($x,$y,$z)) {

        my $k=join(",",@$n);

        $p2++ if exists $outside{$k};
    }
}



print "2022 day18: pl_ans_1: $p1\n";
print "2022 day18: pl_ans_2: $p2\n";

#!/usr/bin/perl
use strict;
use warnings;

sub seat_id {
    my ($code)=@_;

    my $row=0;
    my $col=0;

    foreach my $c (split //, substr($code,0,7)){
        $row <<= 1;
        $row |= 1 if $c eq "B";
    }

    foreach my $c (split //, substr($code,7,3)){
        $col <<= 1;
        $col |= 1 if $c eq "R";
    }

    return $row*8+$col;
}

my $file=shift;

open(my $fh,"<",$file) or die;

my @seats;

while(<$fh>){
    chomp;
    next unless length;
    push @seats, seat_id($_);
}

close($fh);

my $p1=0;
my %seen;

foreach(@seats){
    $seen{$_}=1;
    $p1=$_ if $_>$p1;
}

my $min=$seats[0];
my $max=$seats[0];

foreach(@seats){
    $min=$_ if $_<$min;
    $max=$_ if $_>$max;
}

my $p2;

for(my $i=$min;$i<=$max;$i++){
    if(
        !$seen{$i}
        &&
        $seen{$i-1}
        &&
        $seen{$i+1}
    ){
        $p2=$i;
        last;
    }
}

print "2020 day5: pl_ans_1: $p1\n";
print "2020 day5: pl_ans_2: $p2\n";

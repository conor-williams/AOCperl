#!/usr/bin/perl
use strict;
use warnings;


sub parse {

    my ($line)=@_;

    my ($a,$b)=split /,/, $line;

    my ($a1,$a2)=split /-/, $a;
    my ($b1,$b2)=split /-/, $b;

    return ($a1,$a2,$b1,$b2);
}



my $file = $ARGV[0] or die "usage: perl year2022_day4.pl input.txt\n";

open(my $fh,"<",$file) or die "$!\n";


my @lines;

while (<$fh>) {
    chomp;
    push @lines,$_
        if $_ ne "";
}

close($fh);



my $p1=0;
my $p2=0;


for my $line (@lines) {

    my ($a1,$a2,$b1,$b2)=parse($line);


    # full containment
    if (
        ($a1 <= $b1 && $a2 >= $b2)
        ||
        ($b1 <= $a1 && $b2 >= $a2)
    ) {
        $p1++;
    }


    # overlap
    if (!($a2 < $b1 || $b2 < $a1)) {
        $p2++;
    }
}


print "2022 day4: pl_ans_1: $p1\n";
print "2022 day4: pl_ans_2: $p2\n";

#!/usr/bin/perl
use strict;
use warnings;


sub solve {

    my ($ga,$gb,$iterations,$needs_multiple) = @_;

    my $count = 0;


    for (my $i=0; $i<$iterations; $i++) {


        while (1) {

            $ga *= 16807;
            $ga %= 2147483647;


            if (!$needs_multiple || $ga % 4 == 0) {
                last;
            }
        }



        while (1) {

            $gb *= 48271;
            $gb %= 2147483647;


            if (!$needs_multiple || $gb % 8 == 0) {
                last;
            }
        }



        if (($ga & 65535) == ($gb & 65535)) {

            $count++;
        }
    }


    return $count;
}



open(my $fh,"<",$ARGV[0]) or die "Cannot open file\n";


my @valsx;


while (<$fh>) {

    my $line = $_;

    chomp($line);

    my ($te,$valx) = split(/with /,$line);

    push @valsx,$valx;
}


close($fh);



print "2017 day15: pl_ans_1: ",
      solve(int($valsx[0]), int($valsx[1]), 40000000, 0),
      "\n";


print "2017 day15: pl_ans_2: ",
      solve(int($valsx[0]), int($valsx[1]), 5000000, 1),
      "\n";

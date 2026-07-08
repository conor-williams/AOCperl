#!/usr/bin/perl
use strict;
use warnings;


sub score {

    my ($a,$b)=@_;

    my %opp = (
        A => 0,
        B => 1,
        C => 2
    );

    my %me = (
        X => 0,
        Y => 1,
        Z => 2
    );


    my $o=$opp{$a};
    my $m=$me{$b};


    my $shape=$m+1;

    my $outcome;


    if ($m==$o) {
        $outcome=3;
    }
    elsif ((($m-$o)%3)==1) {
        $outcome=6;
    }
    else {
        $outcome=0;
    }


    return $shape+$outcome;
}



sub score_part2 {

    my ($a,$b)=@_;


    my %opp = (
        A => 0,
        B => 1,
        C => 2
    );


    my $o=$opp{$a};

    my ($m,$outcome);


    if ($b eq "Y") {

        # draw
        $m=$o;
        $outcome=3;

    }
    elsif ($b eq "Z") {

        # win
        $m=($o+1)%3;
        $outcome=6;

    }
    else {

        # lose
        $m=($o-1)%3;
        $outcome=0;
    }


    return ($m+1)+$outcome;
}



my $file=$ARGV[0] or die "usage: perl year2022_day2.pl input.txt\n";


open my $fh,"<",$file or die "$!\n";


my ($p1,$p2)=(0,0);


while (<$fh>) {

    chomp;

    next if /^\s*$/;


    my ($a,$b)=split;


    $p1 += score($a,$b);

    $p2 += score_part2($a,$b);
}


close $fh;


print "2022 day2: pl_ans_1: $p1\n";
print "2022 day2: pl_ans_2: $p2\n";

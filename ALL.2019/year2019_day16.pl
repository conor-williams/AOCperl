#!/usr/bin/perl

use strict;
use warnings;


my @BASE = (0,1,0,-1);



sub build_pattern {

    my ($position,$length)=@_;

    my @pattern;


    for my $v (@BASE) {

        push @pattern, ($v) x ($position+1);
    }


    while (@pattern <= $length) {

        push @pattern,@pattern;
    }


    shift @pattern;

    return @pattern[0..$length-1];
}



sub fft_phase {

    my ($signal)=@_;

    my $n=@$signal;

    my @out;


    for my $i (0..$n-1) {


        my @pattern =
            build_pattern($i,$n);


        my $total=0;


        for my $j (0..$n-1) {

            $total +=
                $signal->[$j] *
                $pattern[$j];
        }


        push @out,
            abs($total)%10;
    }


    return \@out;
}



sub part1 {

    my ($signal)=@_;


    my @s=@$signal;


    for (1..100) {

        @s=@{fft_phase(\@s)};
    }


    return join '', @s[0..7];
}



sub part2 {

    my ($signal)=@_;


    my $offset =
        join('',@$signal[0..6]);


    $offset=int($offset);



    my @full;


    for (1..10000) {

        push @full,@$signal;
    }



    my @suffix =
        @full[$offset..$#full];



    for (1..100) {


        my $running=0;


        for (my $i=$#suffix;$i>=0;$i--) {


            $running =
                ($running+$suffix[$i])%10;


            $suffix[$i]=$running;
        }
    }


    return join '', @suffix[0..7];
}



open my $fh,'<',$ARGV[0] or die $!;

my $text=<$fh>;

close $fh;


chomp $text;


my @signal =
    map {int($_)}
    split //,$text;



my $p1=part1(\@signal);

my $p2=part2(\@signal);



print "2019 day16: pl_ans_1: $p1\n";
print "2019 day16: pl_ans_2: $p2\n";

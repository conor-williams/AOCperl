#!/usr/bin/perl
use strict;
use warnings;


my $DAY=25;


my $file=$ARGV[0];


open(my $fh,"<",$file) or die $!;

my @data=<$fh>;

close($fh);



chomp @data;



my %SNAFU = (

    "2" => 2,
    "1" => 1,
    "0" => 0,
    "-" => -1,
    "=" => -2,

);



my %REV = (

    2  => "2",
    1  => "1",
    0  => "0",
    -1 => "-",
    -2 => "=",

);



sub snafu_to_int {

    my ($s)=@_;


    my $value=0;


    foreach my $ch (split(//,$s)) {

        $value =
            $value*5 + $SNAFU{$ch};
    }


    return $value;
}



sub int_to_snafu {

    my ($n)=@_;


    return "0"
        if $n==0;


    my @digits;


    while($n != 0) {


        my $r=$n % 5;


        $n=int($n/5);



        if($r>2) {

            $r-=5;
            $n++;
        }


        push @digits,$REV{$r};
    }


    return join("",reverse @digits);
}



sub part1 {

    my ($data)=@_;


    my $total=0;


    foreach my $line (@$data) {

        next if $line eq "";

        $total += snafu_to_int($line);
    }


    return int_to_snafu($total);
}



sub part2 {

    return "Merry Christmas!";
}



my $p1=part1(\@data);

my $p2=part2(\@data);



print "2022 day25: pl_ans_1: $p1\n";
print "2022 day25: pl_ans_2: $p2\n";

#!/usr/bin/perl
use strict;
use warnings;


my $file=$ARGV[0];


open(my $fh,"<",$file) or die $!;

my @nums;

while(<$fh>) {
    chomp;
    push @nums, int($_) if $_ ne "";
}

close($fh);



sub mix {

    my ($nums,$rounds)=@_;

    my $n=@$nums;


    # array of [original_index,value]
    my @arr;

    for(my $i=0;$i<$n;$i++) {
        push @arr, [$i,$nums->[$i]];
    }



    for(my $r=0;$r<$rounds;$r++) {


        for(my $i=0;$i<$n;$i++) {


            my $pos;


            for(my $j=0;$j<@arr;$j++) {

                if($arr[$j]->[0]==$i) {

                    $pos=$j;
                    last;
                }
            }


            my $item=$arr[$pos];

            my $val=$item->[1];


            splice(@arr,$pos,1);


            my $newpos =
                ($pos + $val) % ($n-1);


            # Perl modulo can be negative
            $newpos += ($n-1)
                if $newpos < 0;


            splice(@arr,$newpos,0,$item);
        }
    }


    return \@arr;
}



sub grove {

    my ($arr)=@_;

    my $n=@$arr;


    my $zero;


    for(my $i=0;$i<$n;$i++) {

        if($arr->[$i]->[1]==0) {

            $zero=$i;
            last;
        }
    }


    my $sum=0;


    foreach my $offset (1000,2000,3000) {

        my $idx=($zero+$offset)%$n;

        $sum += $arr->[$idx]->[1];
    }


    return $sum;
}



# Part 1

my $arr1=mix(\@nums,1);

my $p1=grove($arr1);



# Part 2

my $KEY=811589153;


my @nums2 =
    map { $_ * $KEY } @nums;


my $arr2=mix(\@nums2,10);


my $p2=grove($arr2);



print "2022 day20: pl_ans_1: $p1\n";
print "2022 day20: pl_ans_2: $p2\n";

#!/usr/bin/perl
use strict;
use warnings;


# ============================================================
# Load program
# ============================================================

my $file = shift @ARGV;

open my $fh, "<", $file or die $!;
my @program = split /,/, <$fh>;
close $fh;



# ============================================================
# Intcode beam test
# ============================================================

sub run_beam {

    my ($prog,$x,$y)=@_;

    my @mem = (@$prog, (0) x 10000);

    my $ip = 0;
    my $rb = 0;

    my @inp = ($x,$y);
    my $inp_pos = 0;


    sub get_value {

        my ($mem,$addr,$mode,$rb)=@_;

        return $mem->[$addr] if $mode == 0;
        return $addr if $mode == 1;
        return $mem->[$rb+$addr] if $mode == 2;

        die "bad mode";
    }


    sub get_addr {

        my ($addr,$mode,$rb)=@_;

        return $addr if $mode == 0;
        return $rb+$addr if $mode == 2;

        die "bad write mode";
    }



    while(1){

        my $instruction=$mem[$ip];

        my $op=$instruction % 100;

        my $m1=int($instruction/100)%10;
        my $m2=int($instruction/1000)%10;
        my $m3=int($instruction/10000)%10;



        if($op==99){
            last;
        }


        elsif($op==1){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            $mem[get_addr($mem[$ip+3],$m3,$rb)]
                =$a+$b;

            $ip+=4;
        }


        elsif($op==2){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            $mem[get_addr($mem[$ip+3],$m3,$rb)]
                =$a*$b;

            $ip+=4;
        }


        elsif($op==3){

            my $addr=get_addr($mem[$ip+1],$m1,$rb);

            $mem[$addr]=$inp[$inp_pos++];

            $ip+=2;
        }


        elsif($op==4){

            return get_value(
                \@mem,
                $mem[$ip+1],
                $m1,
                $rb
            );
        }


        elsif($op==5){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            if($a!=0){
                $ip=$b;
            }
            else{
                $ip+=3;
            }
        }


        elsif($op==6){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            if($a==0){
                $ip=$b;
            }
            else{
                $ip+=3;
            }
        }


        elsif($op==7){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            $mem[get_addr($mem[$ip+3],$m3,$rb)]
                =($a<$b)?1:0;

            $ip+=4;
        }


        elsif($op==8){

            my $a=get_value(\@mem,$mem[$ip+1],$m1,$rb);
            my $b=get_value(\@mem,$mem[$ip+2],$m2,$rb);

            $mem[get_addr($mem[$ip+3],$m3,$rb)]
                =($a==$b)?1:0;

            $ip+=4;
        }


        elsif($op==9){

            $rb += get_value(
                \@mem,
                $mem[$ip+1],
                $m1,
                $rb
            );

            $ip+=2;
        }


        else {
            die "bad opcode $op";
        }
    }


    return 0;
}



# ============================================================
# Part 1
# ============================================================

sub part1 {

    my $sum=0;

    for my $y(0..49){

        for my $x(0..49){

            $sum += run_beam(\@program,$x,$y);
        }
    }

    return $sum;
}



# ============================================================
# Part 2
# ============================================================

sub part2 {

    my $y=100;
    my $x=0;


    while(1){

        while(run_beam(\@program,$x,$y)==0){
            $x++;
        }


        if(run_beam(\@program,$x+99,$y-99)){

            return $x*10000 + ($y-99);
        }


        $y++;
    }
}



print "2019 day19: pl_ans_1: ", part1(), "\n";
print "2019 day19: pl_ans_2: ", part2(), "\n";

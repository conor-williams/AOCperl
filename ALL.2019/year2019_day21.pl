#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;


# ------------------------------------------------------------
# Intcode
# ------------------------------------------------------------

sub run_intcode {

    my ($program, $input_ref) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }


    my $ip = 0;
    my $base = 0;

    my @out;


    my $get = sub {
        my ($addr,$mode)=@_;

        if ($mode == 0) {
            return $mem{$mem{$addr} // 0} // 0;
        }
        elsif ($mode == 1) {
            return $mem{$addr} // 0;
        }
        elsif ($mode == 2) {
            return $mem{$base + ($mem{$addr} // 0)} // 0;
        }
    };


    my $set = sub {
        my ($addr,$mode,$value)=@_;

        if ($mode == 2) {
            $mem{$base + ($mem{$addr} // 0)} = $value;
        }
        else {
            $mem{$mem{$addr} // 0} = $value;
        }
    };



    my $input_pos=0;


    while (1) {


        my $op=$mem{$ip} // 0;


        my $m1=int($op/100)%10;
        my $m2=int($op/1000)%10;
        my $m3=int($op/10000)%10;

        $op %= 100;



        if ($op == 99) {

            last;

        }


        elsif ($op == 1) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            $set->(
                $ip+3,
                $m3,
                $a+$b
            );

            $ip+=4;
        }


        elsif ($op == 2) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            $set->(
                $ip+3,
                $m3,
                $a*$b
            );

            $ip+=4;
        }


        elsif ($op == 3) {

            my $v=$input_ref->[$input_pos++];

            $set->(
                $ip+1,
                $m1,
                $v
            );

            $ip+=2;
        }


        elsif ($op == 4) {

            push @out,
                $get->($ip+1,$m1);

            $ip+=2;
        }


        elsif ($op == 5) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            if ($a != 0) {
                $ip=$b;
            }
            else {
                $ip+=3;
            }
        }


        elsif ($op == 6) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            if ($a == 0) {
                $ip=$b;
            }
            else {
                $ip+=3;
            }
        }


        elsif ($op == 7) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            $set->(
                $ip+3,
                $m3,
                $a<$b ? 1 : 0
            );

            $ip+=4;
        }


        elsif ($op == 8) {

            my $a=$get->($ip+1,$m1);
            my $b=$get->($ip+2,$m2);

            $set->(
                $ip+3,
                $m3,
                $a==$b ? 1 : 0
            );

            $ip+=4;
        }


        elsif ($op == 9) {

            $base += $get->($ip+1,$m1);

            $ip+=2;
        }


        else {

            die "Bad opcode $op at $ip\n";

        }
    }


    return @out;
}



# ------------------------------------------------------------
# Run springdroid
# ------------------------------------------------------------

sub solve {

    my ($program,$script)=@_;


    my @input;


    for my $c (split //,$script."\n") {
        push @input, ord($c);
    }


    my @out=run_intcode(
        $program,
        \@input
    );


    return $out[-1];
}



# ------------------------------------------------------------
# Load input
# ------------------------------------------------------------

my $file=shift @ARGV;

open(my $fh,"<",$file) or die $!;

my $text=<$fh>;

close($fh);


chomp $text;


my @program =
    map { int($_) }
    split /,/,
    $text;



# ------------------------------------------------------------
# Part 1
# ------------------------------------------------------------

my $part1_script = join("\n",

    "NOT A J",
    "NOT B T",
    "OR T J",
    "NOT C T",
    "OR T J",
    "AND D J",
    "WALK"
);



# ------------------------------------------------------------
# Part 2
# ------------------------------------------------------------

my $part2_script = join("\n",

    "NOT A J",
    "NOT B T",
    "OR T J",
    "NOT C T",
    "OR T J",
    "AND D J",
    "NOT E T",
    "NOT T T",
    "OR H T",
    "AND T J",
    "RUN"
);



print "2019 day21: pl_ans_1: ",
      solve(\@program,$part1_script),
      "\n";


print "2019 day21: pl_ans_2: ",
      solve(\@program,$part2_script),
      "\n";

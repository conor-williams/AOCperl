#!/usr/bin/perl
use strict;
use warnings;


# ------------------------------------------------------------
# Modular helpers
# ------------------------------------------------------------

sub mod {
    my ($a,$m)=@_;

    $a %= $m;
    $a += $m if $a < 0;

    return $a;
}


sub mul_mod {

    my ($a,$b,$m)=@_;

    my $result=0;

    $a=mod($a,$m);
    $b=mod($b,$m);


    while ($b>0) {

        $result=mod($result+$a,$m)
            if ($b & 1);

        $a=mod($a*2,$m);

        $b=int($b/2);
    }

    return $result;
}



sub pow_mod {

    my ($a,$n,$m)=@_;

    my $result=1;

    $a=mod($a,$m);


    while ($n>0) {

        if ($n & 1) {
            $result=mul_mod(
                $result,
                $a,
                $m
            );
        }

        $a=mul_mod(
            $a,
            $a,
            $m
        );

        $n=int($n/2);
    }

    return $result;
}



sub egcd {

    my ($a,$b)=@_;

    if ($b==0) {
        return ($a,1,0);
    }


    my ($g,$x1,$y1)=egcd(
        $b,
        $a % $b
    );


    return (
        $g,
        $y1,
        $x1-int($a/$b)*$y1
    );
}



sub modinv {

    my ($a,$m)=@_;

    my ($g,$x,$y)=egcd(
        $a,
        $m
    );


    die "No inverse\n"
        if $g != 1;


    return mod($x,$m);
}



# ------------------------------------------------------------
# Parse shuffle instructions
# affine: new_position = a*x+b mod n
# ------------------------------------------------------------

sub parse {

    my ($lines,$n)=@_;


    my ($a,$b)=(1,0);


    for my $line (@$lines) {


        if ($line eq "deal into new stack") {


            $a=mod(-$a,$n);
            $b=mod(-$b-1,$n);


        }


        elsif ($line =~ /^cut (-?\d+)/) {


            my $k=$1;

            $b=mod(
                $b-$k,
                $n
            );


        }


        elsif ($line =~ /^deal with increment (\d+)/) {


            my $k=$1;

            $a=mul_mod(
                $a,
                $k,
                $n
            );


            $b=mul_mod(
                $b,
                $k,
                $n
            );

        }

    }


    return ($a,$b);
}



sub apply {

    my ($a,$b,$x,$n)=@_;

    return mod(
        mul_mod($a,$x,$n)+$b,
        $n
    );
}



# ------------------------------------------------------------
# Part 1
# ------------------------------------------------------------

sub part1 {

    my ($lines)=@_;

    my $n=10007;


    my ($a,$b)=parse(
        $lines,
        $n
    );


    return apply(
        $a,
        $b,
        2019,
        $n
    );
}



# ------------------------------------------------------------
# Part 2
# ------------------------------------------------------------

sub solve {

    my ($deck,$shuffles,$repeat,$target)=@_;


    # First get the forward shuffle
    my ($a,$b)=parse(
        $shuffles,
        $deck
    );


    # Repeat affine transform:
    #
    # aK = a^K
    #
    my $aK = pow_mod(
        $a,
        $repeat,
        $deck
    );


    my $bK;


    if ($a == 1) {

        $bK = mul_mod(
            $b,
            $repeat,
            $deck
        );

    }
    else {

        # b*(1-a^K)/(1-a)

        my $top = mod(
            1-$aK,
            $deck
        );

        my $bottom = modinv(
            mod(1-$a,$deck),
            $deck
        );


        $bK = mul_mod(
            mul_mod(
                $b,
                $top,
                $deck
            ),
            $bottom,
            $deck
        );
    }


    # invert:
    #
    # x = (target - bK) / aK
    #

    my $inv_aK = modinv(
        $aK,
        $deck
    );


    return mul_mod(
        mod(
            $target-$bK,
            $deck
        ),
        $inv_aK,
        $deck
    );
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

my $file=shift @ARGV;


open(my $fh,"<",$file) or die $!;

my @lines=<$fh>;

close($fh);


chomp @lines;



print "2019 day22: pl_ans_1: ",
      part1(\@lines),
      "\n";



my $N=119315717514047;
my $K=101741582076661;
my $TARGET=2020;


print "2019 day22: pl_ans_2: ",
      solve(
          $N,
          \@lines,
          $K,
          $TARGET
      ),
      "\n";

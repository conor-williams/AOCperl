use strict;
use warnings;


my $path = $ARGV[0] // '../input/17';

open my $fh,'<',$path or die "$path: $!";

local $/;
my $data=<$fh>;

close $fh;


my ($reg,$prog_text)=split /\n\n/,$data;


my @prog = map { int($_) }
           split /,/, ($prog_text =~ /: (.*)/)[0];


my ($rega,$regb,$regc);

for my $line (split /\n/,$reg) {

    if ($line =~ /Register A: (\d+)/) {
        $rega=$1;
    }
    elsif ($line =~ /Register B: (\d+)/) {
        $regb=$1;
    }
    elsif ($line =~ /Register C: (\d+)/) {
        $regc=$1;
    }
}


sub get_combo {

    my ($oper,$a,$b,$c)=@_;

    return $oper if $oper >=0 && $oper <=3;

    return $a if $oper==4;
    return $b if $oper==5;
    return $c if $oper==6;
}


sub run {

    my ($prog,$a,$b,$c)=@_;

    my $ip=0;
    my @out;


    while ($ip < @$prog) {

        my $opcode=$prog->[$ip];
        my $oper=$prog->[$ip+1];

        my $combo=get_combo($oper,$a,$b,$c);


        if ($opcode==0) {
            $a=int($a / (2 ** $combo));
        }
        elsif ($opcode==1) {
            $b ^= $oper;
        }
        elsif ($opcode==2) {
            $b=$combo % 8;
        }
        elsif ($opcode==3) {

            if ($a) {
                $ip=$oper;
                next;
            }
        }
        elsif ($opcode==4) {
            $b ^= $c;
        }
        elsif ($opcode==5) {
            push @out,$combo % 8;
        }
        elsif ($opcode==6) {
            $b=int($a / (2 ** $combo));
        }
        elsif ($opcode==7) {
            $c=int($a / (2 ** $combo));
        }


        $ip+=2;
    }


    return \@out;
}


my $out=run(\@prog,$rega,$regb,$regc);

print "2024 day17: pl_ans_1: ",
      join(",",@$out), "\n";


$rega=0;

my $j=1;
my $istart=0;


while ($j <= @prog && $j >= 0) {

    $rega <<= 3;

    my $found=0;
    my $found_i;


    for my $i ($istart .. 7) {

        my $r=run(\@prog,$rega+$i,$regb,$regc);

        my @tail=@prog[-$j .. -1];

        if (join(",",@tail) eq join(",",@$r)) {

            $found=1;
            $found_i=$i;
            last;
        }
    }


    if (!$found) {

        $j--;

        $rega >>= 3;

        $istart=($rega % 8)+1;

        $rega >>= 3;

        next;
    }


    $j++;

    $rega += $found_i;

    $istart=0;
}


print "2024 day17: pl_ans_2: $rega\n";

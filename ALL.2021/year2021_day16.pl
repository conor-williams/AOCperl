use strict;
#use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my $hex = <$fh>;

chomp $hex;

close $fh;



sub hex_to_bin {

    my ($s)=@_;

    my %map = (
        0=>"0000",1=>"0001",2=>"0010",3=>"0011",
        4=>"0100",5=>"0101",6=>"0110",7=>"0111",
        8=>"1000",9=>"1001",A=>"1010",B=>"1011",
        C=>"1100",D=>"1101",E=>"1110",F=>"1111"
    );

    my $out="";

    for my $c (split //, uc($s)) {

        $out .= $map{$c};
    }

    return $out;
}



sub parse_packet {

    my ($bits,$pos)=@_;


    my $version =
        oct("0b".substr($bits,$$pos,3));

    $$pos += 3;


    my $type =
        oct("0b".substr($bits,$$pos,3));

    $$pos += 3;


    my $version_sum=$version;


    # literal

    if ($type == 4) {

        my $valbits="";


        while (1) {

            my $group=substr($bits,$$pos,1);

            $valbits .= substr($bits,$$pos+1,4);

            $$pos += 5;


            last if $group eq "0";
        }


        return ($version_sum,oct("0b".$valbits));
    }



    my @values;


    my $length_type=substr($bits,$$pos,1);

    $$pos++;


    if ($length_type eq "0") {


        my $len =
            oct("0b".substr($bits,$$pos,15));

        $$pos += 15;


        my $end=$$pos+$len;


        while ($$pos < $end) {

            my ($v,$x)=parse_packet($bits,$pos);

            $version_sum += $v;

            push @values,$x;
        }

    }
    else {


        my $count =
            oct("0b".substr($bits,$$pos,11));

        $$pos += 11;


        for (1..$count) {

            my ($v,$x)=parse_packet($bits,$pos);

            $version_sum += $v;

            push @values,$x;
        }
    }



    my $value;


    if ($type == 0) {

        $value=0;

        $value += $_ for @values;

    }
    elsif ($type == 1) {

        $value=1;

        $value *= $_ for @values;

    }
    elsif ($type == 2) {

        $value=$values[0];

        for (@values) {
            $value=$_ if $_<$value;
        }

    }
    elsif ($type == 3) {

        $value=$values[0];

        for (@values) {
            $value=$_ if $_>$value;
        }

    }
    elsif ($type == 5) {

        $value=($values[0] > $values[1]) ? 1:0;

    }
    elsif ($type == 6) {

        $value=($values[0] < $values[1]) ? 1:0;

    }
    elsif ($type == 7) {

        $value=($values[0] == $values[1]) ? 1:0;
    }


    return ($version_sum,$value);
}



my $bits=hex_to_bin($hex);

my $pos=0;

my ($p1,$p2)=parse_packet($bits,\$pos);


print "2021 day16: pl_ans_1: $p1\n";
print "2021 day16: pl_ans_2: $p2\n";

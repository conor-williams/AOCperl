use strict;
use warnings;


my $file = shift;


open(my $fh,"<",$file) or die $!;

my @lines = <$fh>;

close($fh);



# ------------------------------------------------------------
# Hex directions (axial coordinates)
# ------------------------------------------------------------

my %DIR = (

    e  => [1,0],
    w  => [-1,0],
    ne => [1,-1],
    nw => [0,-1],
    se => [0,1],
    sw => [-1,1],

);



# ------------------------------------------------------------
# Parse one line
# ------------------------------------------------------------

sub parse_line {

    my ($line)=@_;

    my @steps;

    my $i=0;


    while ($i < length($line)) {


        my $c=substr($line,$i,1);


        if ($c eq "e" || $c eq "w") {

            push @steps,$c;

            $i++;

        }
        else {

            push @steps,
                substr($line,$i,2);

            $i+=2;

        }

    }


    return @steps;

}



# ------------------------------------------------------------
# Follow path
# ------------------------------------------------------------

sub follow {


    my (@steps)=@_;


    my ($x,$y)=(0,0);


    foreach my $s (@steps) {


        my ($dx,$dy)=@{$DIR{$s}};


        $x += $dx;
        $y += $dy;

    }


    return ($x,$y);

}



# ------------------------------------------------------------
# Initial black tiles
# ------------------------------------------------------------

my %black;


foreach my $line (@lines) {


    chomp($line);

    next if $line eq "";


    my @steps=parse_line($line);


    my ($x,$y)=follow(@steps);


    my $key="$x,$y";


    if (exists $black{$key}) {

        delete $black{$key};

    }
    else {

        $black{$key}=1;

    }

}



my $ans1=scalar(keys %black);



# ------------------------------------------------------------
# Neighbours
# ------------------------------------------------------------

sub neighbors {


    my ($x,$y)=@_;


    my @out;


    foreach my $d (values %DIR) {


        push @out,
            [
                $x+$d->[0],
                $y+$d->[1]
            ];

    }


    return @out;

}



# ------------------------------------------------------------
# Simulate
# ------------------------------------------------------------

for (1..100) {


    my %check;


    foreach my $key (keys %black) {


        my ($x,$y)=split(/,/,$key);


        $check{$key}=1;


        foreach my $n (neighbors($x,$y)) {


            my $nk="$n->[0],$n->[1]";

            $check{$nk}=1;

        }

    }



    my %new;


    foreach my $key (keys %check) {


        my ($x,$y)=split(/,/,$key);


        my $count=0;


        foreach my $n (neighbors($x,$y)) {


            my $nk="$n->[0],$n->[1]";


            $count++
                if exists $black{$nk};

        }



        if (exists $black{$key}) {


            if ($count==1 || $count==2) {

                $new{$key}=1;

            }

        }
        else {


            if ($count==2) {

                $new{$key}=1;

            }

        }

    }


    %black=%new;

}



my $ans2=scalar(keys %black);



print "2020 day24: pl_ans_1: $ans1\n";
print "2020 day24: pl_ans_2: $ans2\n";

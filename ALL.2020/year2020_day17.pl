use strict;
use warnings;


# ------------------------------------------------------------
# Read input
# ------------------------------------------------------------

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @data;

while (<$fh>) {
    chomp;
    push @data, $_ if $_ ne "";
}

close($fh);



# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

sub key3 {
    my ($x,$y,$z) = @_;
    return "$x,$y,$z";
}


sub key4 {
    my ($x,$y,$z,$w) = @_;
    return "$x,$y,$z,$w";
}



# ------------------------------------------------------------
# Part 1 - 3D
# ------------------------------------------------------------

sub solve3 {


    my %active = @_;


    for (1..6) {


        my %new;


        my ($minx,$maxx,$miny,$maxy,$minz,$maxz);


        foreach my $k (keys %active) {

            my ($x,$y,$z) = split(/,/, $k);

            $minx = $x if !defined($minx) || $x < $minx;
            $maxx = $x if !defined($maxx) || $x > $maxx;

            $miny = $y if !defined($miny) || $y < $miny;
            $maxy = $y if !defined($maxy) || $y > $maxy;

            $minz = $z if !defined($minz) || $z < $minz;
            $maxz = $z if !defined($maxz) || $z > $maxz;
        }


        for my $x ($minx-1 .. $maxx+1) {
            for my $y ($miny-1 .. $maxy+1) {
                for my $z ($minz-1 .. $maxz+1) {


                    my $cnt = 0;


                    for my $dx (-1..1) {
                        for my $dy (-1..1) {
                            for my $dz (-1..1) {


                                next
                                    if $dx==0 && $dy==0 && $dz==0;


                                $cnt++
                                    if exists $active{key3(
                                        $x+$dx,
                                        $y+$dy,
                                        $z+$dz
                                    )};
                            }
                        }
                    }


                    my $k = key3($x,$y,$z);


                    if (exists $active{$k}) {

                        $new{$k}=1
                            if $cnt==2 || $cnt==3;

                    } else {

                        $new{$k}=1
                            if $cnt==3;
                    }
                }
            }
        }


        %active = %new;
    }


    return scalar keys %active;
}



# ------------------------------------------------------------
# Part 2 - 4D
# ------------------------------------------------------------

sub solve4 {


    my %active = @_;


    for (1..6) {


        my %new;


        my ($minx,$maxx,$miny,$maxy,$minz,$maxz,$minw,$maxw);


        foreach my $k (keys %active) {

            my ($x,$y,$z,$w)=split(/,/, $k);


            $minx=$x if !defined($minx)||$x<$minx;
            $maxx=$x if !defined($maxx)||$x>$maxx;

            $miny=$y if !defined($miny)||$y<$miny;
            $maxy=$y if !defined($maxy)||$y>$maxy;

            $minz=$z if !defined($minz)||$z<$minz;
            $maxz=$z if !defined($maxz)||$z>$maxz;

            $minw=$w if !defined($minw)||$w<$minw;
            $maxw=$w if !defined($maxw)||$w>$maxw;
        }



        for my $x ($minx-1 .. $maxx+1) {
            for my $y ($miny-1 .. $maxy+1) {
                for my $z ($minz-1 .. $maxz+1) {
                    for my $w ($minw-1 .. $maxw+1) {


                        my $cnt=0;


                        for my $dx (-1..1) {
                            for my $dy (-1..1) {
                                for my $dz (-1..1) {
                                    for my $dw (-1..1) {


                                        next
                                            if $dx==0 &&
                                               $dy==0 &&
                                               $dz==0 &&
                                               $dw==0;


                                        $cnt++
                                            if exists $active{key4(
                                                $x+$dx,
                                                $y+$dy,
                                                $z+$dz,
                                                $w+$dw
                                            )};

                                    }
                                }
                            }
                        }


                        my $k=key4($x,$y,$z,$w);


                        if (exists $active{$k}) {

                            $new{$k}=1
                                if $cnt==2 || $cnt==3;

                        } else {

                            $new{$k}=1
                                if $cnt==3;
                        }

                    }
                }
            }
        }


        %active=%new;
    }


    return scalar keys %active;
}



# ------------------------------------------------------------
# Build initial states
# ------------------------------------------------------------

my %start3;


for my $y (0..$#data) {

    my @row = split(//,$data[$y]);

    for my $x (0..$#row) {

        if ($row[$x] eq "#") {

            $start3{key3($y,$x,0)}=1;
        }
    }
}



my %start4;


for my $y (0..$#data) {

    my @row=split(//,$data[$y]);

    for my $x (0..$#row) {

        if ($row[$x] eq "#") {

            $start4{key4($y,$x,0,0)}=1;
        }
    }
}



# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

print "2020 day17: pl_ans_1: ", solve3(%start3), "\n";

print "2020 day17: pl_ans_2: ", solve4(%start4), "\n";

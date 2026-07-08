#!/usr/bin/perl
use strict;
use warnings;


my $file = shift @ARGV;

open(my $fh, "<", $file) or die $!;
my @grid = <$fh>;
close($fh);

chomp @grid;


my $h = scalar @grid;
my $w = 0;

for my $row (@grid) {
    $w = length($row) if length($row) > $w;
}

for my $y (0 .. $h-1) {
    $grid[$y] .= " " x ($w - length($grid[$y]));
}


sub upper {
    my ($c) = @_;
    return ($c ge 'A' && $c le 'Z');
}


# ------------------------------------------------------------
# Find portals
# ------------------------------------------------------------

sub find_portals {

    my ($grid,$w,$h)=@_;

    my %portals;


    for my $y (0..$h-1) {
        for my $x (0..$w-1) {


            my $c=substr($grid->[$y],$x,1);

            next unless upper($c);


            # horizontal

            if ($x+1<$w &&
                upper(substr($grid->[$y],$x+1,1))) {


                my $name =
                    $c.substr($grid->[$y],$x+1,1);


                if ($x-1>=0 &&
                    substr($grid->[$y],$x-1,1) eq ".") {

                    push @{$portals{$name}},
                        [$x-1,$y];


                } elsif ($x+2<$w &&
                    substr($grid->[$y],$x+2,1) eq ".") {

                    push @{$portals{$name}},
                        [$x+2,$y];
                }
            }



            # vertical

            if ($y+1<$h &&
                upper(substr($grid->[$y+1],$x,1))) {


                my $name =
                    $c.substr($grid->[$y+1],$x,1);



                if ($y-1>=0 &&
                    substr($grid->[$y-1],$x,1) eq ".") {

                    push @{$portals{$name}},
                        [$x,$y-1];


                } elsif ($y+2<$h &&
                    substr($grid->[$y+2],$x,1) eq ".") {

                    push @{$portals{$name}},
                        [$x,$y+2];
                }
            }
        }
    }


    return %portals;
}



# ------------------------------------------------------------
# Teleports
# ------------------------------------------------------------

sub build_teleports {

    my (%portals)=@_;

    my %tele;


    for my $name (keys %portals) {

        next unless @{$portals{$name}} == 2;


        my $a=$portals{$name}[0];
        my $b=$portals{$name}[1];


        $tele{"$a->[0],$a->[1]"} =
            [$b->[0],$b->[1]];


        $tele{"$b->[0],$b->[1]"} =
            [$a->[0],$a->[1]];
    }


    return %tele;
}



sub outer {

    my ($x,$y,$w,$h)=@_;


    return 1 if $x<=2;
    return 1 if $y<=2;
    return 1 if $x>=$w-3;
    return 1 if $y>=$h-3;


    return 0;
}



# ------------------------------------------------------------
# Part 1 BFS
# ------------------------------------------------------------

sub bfs1 {

    my ($grid,$tele,$start,$end,$w,$h)=@_;


    my @q;

    push @q,
        [$start->[0],$start->[1],0];


    my %seen;

    $seen{"$start->[0],$start->[1]"}=1;


    my $head=0;


    while ($head < @q) {


        my ($x,$y,$dist)=@{$q[$head++]};


        return $dist
            if $x==$end->[0] &&
               $y==$end->[1];



        for my $d (
            [1,0],
            [-1,0],
            [0,1],
            [0,-1]
        ) {


            my $nx=$x+$d->[0];
            my $ny=$y+$d->[1];


            next if $nx<0 || $ny<0;
            next if $nx>=$w || $ny>=$h;


            next unless
                substr($grid->[$ny],$nx,1) eq ".";


            my $key="$nx,$ny";


            next if exists $seen{$key};


            $seen{$key}=1;


            push @q,
                [$nx,$ny,$dist+1];
        }



        my $key="$x,$y";


        if (exists $tele->{$key}) {


            my $p=$tele->{$key};

            my $nk="$p->[0],$p->[1]";


            unless(exists $seen{$nk}) {


                $seen{$nk}=1;


                push @q,
                    [$p->[0],$p->[1],$dist+1];
            }
        }
    }


    return undef;
}



# ------------------------------------------------------------
# Part 2 recursive BFS
# ------------------------------------------------------------

sub bfs2 {


    my ($grid,$tele,$start,$end,$w,$h)=@_;


    my @q;


    push @q,
        [$start->[0],$start->[1],0,0];


    my %seen;


    $seen{"$start->[0],$start->[1],0"}=1;


    my $head=0;


    while ($head < @q) {


        my ($x,$y,$level,$dist)=@{$q[$head++]};



        return $dist
            if $x==$end->[0] &&
               $y==$end->[1] &&
               $level==0;



        for my $d (
            [1,0],
            [-1,0],
            [0,1],
            [0,-1]
        ) {


            my $nx=$x+$d->[0];
            my $ny=$y+$d->[1];


            next if $nx<0 || $ny<0;
            next if $nx>=$w || $ny>=$h;


            next unless
                substr($grid->[$ny],$nx,1) eq ".";


            my $state="$nx,$ny,$level";


            next if exists $seen{$state};


            $seen{$state}=1;


            push @q,
                [$nx,$ny,$level,$dist+1];
        }



        my $key="$x,$y";


        if (exists $tele->{$key}) {


            my $p=$tele->{$key};


            my $newlevel;


            if (outer($x,$y,$w,$h)) {


                next if $level==0;


                $newlevel=$level-1;


            } else {


                $newlevel=$level+1;
            }



            my $state =
                "$p->[0],$p->[1],$newlevel";


            unless(exists $seen{$state}) {


                $seen{$state}=1;


                push @q,
                    [
                        $p->[0],
                        $p->[1],
                        $newlevel,
                        $dist+1
                    ];
            }
        }
    }


    return undef;
}



# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------


my %portals=find_portals(\@grid,$w,$h);


my $start=$portals{"AA"}->[0];
my $end=$portals{"ZZ"}->[0];


my %tele=build_teleports(%portals);



my $p1=bfs1(
    \@grid,
    \%tele,
    $start,
    $end,
    $w,
    $h
);


my $p2=bfs2(
    \@grid,
    \%tele,
    $start,
    $end,
    $w,
    $h
);



print "2019 day20: pl_ans_1: $p1\n";
print "2019 day20: pl_ans_2: $p2\n";

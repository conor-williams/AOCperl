#!/usr/bin/perl

use strict;
use warnings;
use feature 'state';
no warnings 'recursion';
no warnings 'closure';


my $lenx = 50;
my $leny = 50;

my @grid;
my @already;

for my $y (0..$leny-1) {
    for my $x (0..$lenx-1) {
        $grid[$y][$x] = ' ';
        $already[$y][$x] = 1000000000;
    }
}


my $minPath = 1000000000;



# -------------------------------------------------
# Intcode
# -------------------------------------------------

sub run_intcode {

    my ($program)=@_;


    my %mem;

    for my $i (0..$#$program) {
        $mem{$i}=$program->[$i];
    }


    my $ip=0;
    my $rel=0;


    my $x=int($lenx/2);
    my $y=int($leny/2);


    my $input_val=1;

    my ($ex,$ey)=(0,0);

    my $found=0;


    sub get {

        my ($m,$v)=@_;

        return $mem{$v} // 0 if $m==0;
        return $v if $m==1;
        return $mem{$rel+$v} // 0;
    }


    sub setv {

        my ($m,$v,$val)=@_;

        if ($m==2) {
            $mem{$rel+$v}=$val;
        }
        else {
            $mem{$v}=$val;
        }
    }


    while (1) {


        my $ins =
            sprintf("%05d",$mem{$ip}//0);


        my $op =
            int(substr($ins,3,2));


        my $m1=int(substr($ins,2,1));
        my $m2=int(substr($ins,1,1));
        my $m3=int(substr($ins,0,1));



        last if $op==99;



        if ($op==1 || $op==2 || $op==7 || $op==8) {


            my $a=get($m1,$mem{$ip+1});
            my $b=get($m2,$mem{$ip+2});


            my $dest=$mem{$ip+3};

            $dest += $rel if $m3==2;


            if ($op==1) {
                $mem{$dest}=$a+$b;
            }
            elsif ($op==2) {
                $mem{$dest}=$a*$b;
            }
            elsif ($op==7) {
                $mem{$dest}=($a<$b)?1:0;
            }
            elsif ($op==8) {
                $mem{$dest}=($a==$b)?1:0;
            }


            $ip+=4;
        }



        elsif ($op==3) {

            my $dest=$mem{$ip+1};

            $dest += $rel if $m1==2;


            $mem{$dest}=$input_val;

            $ip+=2;
        }



        elsif ($op==4) {


            my $out=get($m1,$mem{$ip+1});



            if ($out==0) {


                if ($input_val==1) {
                    $grid[$y-1][$x]='#';
                    $input_val=4;
                }
                elsif ($input_val==2) {
                    $grid[$y+1][$x]='#';
                    $input_val=3;
                }
                elsif ($input_val==3) {
                    $grid[$y][$x-1]='#';
                    $input_val=1;
                }
                elsif ($input_val==4) {
                    $grid[$y][$x+1]='#';
                    $input_val=2;
                }

            }


            elsif ($out==1) {


                if ($input_val==1) {
                    $y--;
                    $input_val=3;
                }
                elsif ($input_val==2) {
                    $y++;
                    $input_val=4;
                }
                elsif ($input_val==3) {
                    $x--;
                    $input_val=2;
                }
                elsif ($input_val==4) {
                    $x++;
                    $input_val=1;
                }


                $grid[$y][$x]='.';
            }


            elsif ($out==2) {


                if ($input_val==1) {
                    $y--;
                    $input_val=3;
                }
                elsif ($input_val==2) {
                    $y++;
                    $input_val=4;
                }
                elsif ($input_val==3) {
                    $x--;
                    $input_val=2;
                }
                elsif ($input_val==4) {
                    $x++;
                    $input_val=1;
                }


                $grid[$y][$x]='O';


                ($ex,$ey)=($x,$y);

                $found++;


                last if $found==4;
            }


            $ip+=2;
        }



        elsif ($op==5) {

            my $a=get($m1,$mem{$ip+1});
            my $b=get($m2,$mem{$ip+2});

            $ip =
                $a!=0 ? $b : $ip+3;
        }



        elsif ($op==6) {

            my $a=get($m1,$mem{$ip+1});
            my $b=get($m2,$mem{$ip+2});

            $ip =
                $a==0 ? $b : $ip+3;
        }



        elsif ($op==9) {

            $rel += get($m1,$mem{$ip+1});

            $ip+=2;
        }

    }


    return ($ex,$ey);
}




# -------------------------------------------------
# DFS
# -------------------------------------------------

sub dfs {

    my ($x,$y,$ex,$ey,$path)=@_;


    return if $grid[$y][$x] eq ' ';
    return if $grid[$y][$x] eq '#';


    return if $path >= $already[$y][$x];


    $already[$y][$x]=$path;



    if ($x==$ex && $y==$ey) {

        $minPath=$path if $path<$minPath;

        return;
    }


    dfs($x+1,$y,$ex,$ey,$path+1);
    dfs($x-1,$y,$ex,$ey,$path+1);
    dfs($x,$y+1,$ex,$ey,$path+1);
    dfs($x,$y-1,$ex,$ey,$path+1);
}



# -------------------------------------------------
# main
# -------------------------------------------------

open my $fh,'<',$ARGV[0] or die $!;

chomp(my $line=<$fh>);

close $fh;


my @program =
    map {int($_)}
    split /,/,$line;


push @program,(0)x10000;



for my $y (0..$leny-1) {
    for my $x (0..$lenx-1) {
        $grid[$y][$x]=' ';
        $already[$y][$x]=1000000000;
    }
}



my ($ex,$ey)=run_intcode(\@program);



$minPath=1000000000;

dfs(
    int($lenx/2),
    int($leny/2),
    $ex,
    $ey,
    0
);



print "2019 day15: pl_ans_1: $minPath\n";



# -------------------------------------------------
# Part 2
# -------------------------------------------------

my $max_time=0;


for my $ty (0..$leny-1) {

    for my $tx (0..$lenx-1) {


        next unless $grid[$ty][$tx] eq '.';



        for my $y (0..$leny-1) {

            for my $x (0..$lenx-1) {

                $already[$y][$x]=1000000000;
            }
        }



        $minPath=1000000000;


        dfs(
            $ex,
            $ey,
            $tx,
            $ty,
            0
        );


        if ($minPath != 1000000000) {

            $max_time=$minPath
                if $minPath>$max_time;
        }
    }
}


print "2019 day15: pl_ans_2: $max_time\n";

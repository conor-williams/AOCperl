use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";


my @steps;

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    if (/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$/) {

        my $state = ($1 eq "on") ? 1 : 0;

        push @steps, [
            $state,
            int($2), int($3),
            int($4), int($5),
            int($6), int($7)
        ];
    }
}

close $fh;



# --------------------------------------------------
# cube intersection
# cube format:
# [x1,x2,y1,y2,z1,z2]
# --------------------------------------------------

sub intersect {

    my ($a,$b)=@_;


    my $x1 = $a->[0] > $b->[0] ? $a->[0] : $b->[0];
    my $x2 = $a->[1] < $b->[1] ? $a->[1] : $b->[1];

    my $y1 = $a->[2] > $b->[2] ? $a->[2] : $b->[2];
    my $y2 = $a->[3] < $b->[3] ? $a->[3] : $b->[3];

    my $z1 = $a->[4] > $b->[4] ? $a->[4] : $b->[4];
    my $z2 = $a->[5] < $b->[5] ? $a->[5] : $b->[5];


    return undef if $x1 > $x2;
    return undef if $y1 > $y2;
    return undef if $z1 > $z2;


    return [
        $x1,$x2,
        $y1,$y2,
        $z1,$z2
    ];
}



sub volume {

    my ($c)=@_;

    return
        ($c->[1]-$c->[0]+1) *
        ($c->[3]-$c->[2]+1) *
        ($c->[5]-$c->[4]+1);
}



# --------------------------------------------------
# inclusion / exclusion solver
# --------------------------------------------------

sub solve {

    my ($steps)=@_;


    my @cubes;


    for my $s (@$steps) {

        my ($state,$x1,$x2,$y1,$y2,$z1,$z2)=@$s;


        my $new_cube=[
            $x1,$x2,
            $y1,$y2,
            $z1,$z2
        ];


        my @additions;


        for my $entry (@cubes) {

            my ($cube,$sign)=@$entry;


            my $inter=intersect($cube,$new_cube);


            if (defined $inter) {

                push @additions,
                    [
                        $inter,
                        -$sign
                    ];
            }
        }


        if ($state==1) {

            push @additions,
                [
                    $new_cube,
                    1
                ];
        }


        push @cubes,@additions;
    }


    my $total=0;


    for my $entry (@cubes) {

        my ($cube,$sign)=@$entry;

        $total += $sign * volume($cube);
    }


    return $total;
}



# --------------------------------------------------
# Part 1 clipping
# --------------------------------------------------

sub solve_part1 {

    my ($steps)=@_;

    my @clipped;


    for my $s (@$steps) {

        my ($state,$x1,$x2,$y1,$y2,$z1,$z2)=@$s;


        $x1 = -50 if $x1 < -50;
        $x2 =  50 if $x2 >  50;

        $y1 = -50 if $y1 < -50;
        $y2 =  50 if $y2 >  50;

        $z1 = -50 if $z1 < -50;
        $z2 =  50 if $z2 >  50;


        next if $x1 > $x2;
        next if $y1 > $y2;
        next if $z1 > $z2;


        push @clipped,[
            $state,
            $x1,$x2,
            $y1,$y2,
            $z1,$z2
        ];
    }


    return solve(\@clipped);
}



my $ans1 = solve_part1(\@steps);

my $ans2 = solve(\@steps);



print "2021 day22: pl_ans_1: $ans1\n";
print "2021 day22: pl_ans_2: $ans2\n";

#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Read input
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";


open(my $fh, '<', $file)
    or die "Cannot open $file: $!";


my @bots;


while (my $line = <$fh>)
{
    chomp $line;

    next if $line =~ /^\s*$/;


    my @n = ($line =~ /-?\d+/g);


    push @bots,
    [
        $n[0],
        $n[1],
        $n[2],
        $n[3]
    ];
}


close($fh);



# -------------------------------------------------
# Part 1
# -------------------------------------------------

sub solve_part1
{
    my ($bots) = @_;


    my $strongest = $bots->[0];


    for my $b (@$bots)
    {
        if ($b->[3] > $strongest->[3])
        {
            $strongest = $b;
        }
    }


    my ($sx,$sy,$sz,$sr) = @$strongest;


    my $count = 0;


    for my $b (@$bots)
    {
        my ($x,$y,$z,$r) = @$b;


        my $dist =
            abs($x-$sx) +
            abs($y-$sy) +
            abs($z-$sz);


        $count++ if $dist <= $sr;
    }


    return $count;
}



# -------------------------------------------------
# Box helpers
# -------------------------------------------------

sub make_box
{
    return
    {
        xmin => $_[0],
        xmax => $_[1],
        ymin => $_[2],
        ymax => $_[3],
        zmin => $_[4],
        zmax => $_[5],
    };
}



sub box_distance_to_origin
{
    my ($box) = @_;


    my $dx =
        ($box->{xmin} <= 0 &&
         0 <= $box->{xmax})
        ? 0
        : ($box->{xmin} > 0
            ? $box->{xmin}
            : abs($box->{xmax}));


    my $dy =
        ($box->{ymin} <= 0 &&
         0 <= $box->{ymax})
        ? 0
        : ($box->{ymin} > 0
            ? $box->{ymin}
            : abs($box->{ymax}));


    my $dz =
        ($box->{zmin} <= 0 &&
         0 <= $box->{zmax})
        ? 0
        : ($box->{zmin} > 0
            ? $box->{zmin}
            : abs($box->{zmax}));


    return $dx + $dy + $dz;
}



sub count_in_range
{
    my ($box,$bots) = @_;


    my $count = 0;


    for my $b (@$bots)
    {
        my ($x,$y,$z,$r) = @$b;


        my $dx = 0;
        my $dy = 0;
        my $dz = 0;


        if ($x < $box->{xmin})
        {
            $dx = $box->{xmin} - $x;
        }
        elsif ($x > $box->{xmax})
        {
            $dx = $x - $box->{xmax};
        }


        if ($y < $box->{ymin})
        {
            $dy = $box->{ymin} - $y;
        }
        elsif ($y > $box->{ymax})
        {
            $dy = $y - $box->{ymax};
        }


        if ($z < $box->{zmin})
        {
            $dz = $box->{zmin} - $z;
        }
        elsif ($z > $box->{zmax})
        {
            $dz = $z - $box->{zmax};
        }


        if ($dx + $dy + $dz <= $r)
        {
            $count++;
        }
    }


    return $count;
}



sub subdivide
{
    my ($box) = @_;


    my $mx =
        int(($box->{xmin} + $box->{xmax}) / 2);

    my $my =
        int(($box->{ymin} + $box->{ymax}) / 2);

    my $mz =
        int(($box->{zmin} + $box->{zmax}) / 2);


    my @parts;


    for my $xx
    (
        [$box->{xmin},$mx],
        [$mx+1,$box->{xmax}]
    )
    {
        next if $xx->[0] > $xx->[1];


        for my $yy
        (
            [$box->{ymin},$my],
            [$my+1,$box->{ymax}]
        )
        {
            next if $yy->[0] > $yy->[1];


            for my $zz
            (
                [$box->{zmin},$mz],
                [$mz+1,$box->{zmax}]
            )
            {
                next if $zz->[0] > $zz->[1];


                push @parts,
                    make_box(
                        $xx->[0],
                        $xx->[1],
                        $yy->[0],
                        $yy->[1],
                        $zz->[0],
                        $zz->[1]
                    );
            }
        }
    }


    return @parts;
}



# -------------------------------------------------
# Simple binary heap
# -------------------------------------------------

sub heap_push
{
    my ($heap,$item) = @_;


    push @$heap,$item;


    my $i = @$heap-1;


    while ($i > 0)
    {
        my $p = int(($i-1)/2);


        last if compare_heap(
            $heap->[$p],
            $heap->[$i]
        ) <= 0;


        ($heap->[$p],$heap->[$i]) =
            ($heap->[$i],$heap->[$p]);


        $i=$p;
    }
}



sub heap_pop
{
    my ($heap)=@_;


    my $result=$heap->[0];

    my $last=pop @$heap;


    if (@$heap)
    {
        $heap->[0]=$last;


        my $i=0;


        while (1)
        {
            my $l=$i*2+1;
            my $r=$i*2+2;

            my $best=$i;


            if ($l < @$heap &&
                compare_heap($heap->[$l],$heap->[$best]) < 0)
            {
                $best=$l;
            }


            if ($r < @$heap &&
                compare_heap($heap->[$r],$heap->[$best]) < 0)
            {
                $best=$r;
            }


            last if $best==$i;


            ($heap->[$i],$heap->[$best]) =
                ($heap->[$best],$heap->[$i]);


            $i=$best;
        }
    }


    return $result;
}



sub compare_heap
{
    my ($a,$b)=@_;


    return $a->[0] <=> $b->[0]
        ||
           $a->[1] <=> $b->[1]
        ||
           $a->[2] <=> $b->[2];
}



# -------------------------------------------------
# Part 2
# -------------------------------------------------

sub solve_part2
{
    my ($bots)=@_;


    my (@xs,@ys,@zs);


    for my $b (@$bots)
    {
        push @xs,$b->[0];
        push @ys,$b->[1];
        push @zs,$b->[2];
    }


    my $root =
        make_box(
            (sort {$a<=>$b} @xs)[0],
            (sort {$a<=>$b} @xs)[-1],
            (sort {$a<=>$b} @ys)[0],
            (sort {$a<=>$b} @ys)[-1],
            (sort {$a<=>$b} @zs)[0],
            (sort {$a<=>$b} @zs)[-1]
        );


    my @heap;

    my $uid=0;


    heap_push(
        \@heap,
        [
            0,
            0,
            $uid++,
            $root
        ]
    );


    my $best=0;
    my $best_dist=0;


    while (@heap)
    {
        my ($neg_count,$dist,$id,$box) =
            @{heap_pop(\@heap)};


        my $count_here =
            count_in_range($box,$bots);


        $dist =
            box_distance_to_origin($box);


        next if $count_here < $best;


        if (
            $box->{xmin}==$box->{xmax} &&
            $box->{ymin}==$box->{ymax} &&
            $box->{zmin}==$box->{zmax}
        )
        {
            if (
                $count_here > $best ||
                ($count_here == $best &&
                 $dist < $best_dist)
            )
            {
                $best=$count_here;
                $best_dist=$dist;
            }

            next;
        }


        for my $sub (subdivide($box))
        {
            my $sub_count =
                count_in_range($sub,$bots);


            my $sub_dist =
                box_distance_to_origin($sub);


            heap_push(
                \@heap,
                [
                    -$sub_count,
                    $sub_dist,
                    $uid++,
                    $sub
                ]
            );
        }
    }


    return $best_dist;
}



# -------------------------------------------------
# Main
# -------------------------------------------------

my $p1 = solve_part1(\@bots);
my $p2 = solve_part2(\@bots);


print "2018 day23: pl_ans_1: $p1\n";
print "2018 day23: pl_ans_2: $p2\n";

use strict;
use warnings;


my $file = shift;

open(my $fh,"<",$file) or die $!;

my $input = <$fh>;

close($fh);

chomp($input);


my @cups = map { int($_) } split(//,$input);



# ------------------------------------------------------------
# Part 1
# ------------------------------------------------------------

sub play_part1 {

    my @cups=@{$_[0]};

    my $current_idx=0;

    my $max=0;
    my $min=999999;


    foreach my $c (@cups) {

        $max=$c if $c>$max;
        $min=$c if $c<$min;

    }



    for (1..100) {


        my $current=$cups[$current_idx];


        my @pick;


        my $remove_idx =
            ($current_idx+1) % scalar(@cups);


        for (1..3) {


            if ($remove_idx >= scalar(@cups)) {

                $remove_idx=0;

            }


            push @pick,
                splice(@cups,$remove_idx,1);


        }



        my %picked =
            map { $_=>1 } @pick;


        my $dest=$current-1;


        while ($dest<$min || exists $picked{$dest}) {


            $dest--;


            if ($dest<$min) {

                $dest=$max;

            }

        }



        my $dest_idx;


        for (my $i=0;$i<@cups;$i++) {

            if ($cups[$i]==$dest) {

                $dest_idx=$i;
                last;

            }

        }



        splice(@cups,$dest_idx+1,0,@pick);



        for (my $i=0;$i<@cups;$i++) {

            if ($cups[$i]==$current) {

                $current_idx =
                    ($i+1) % scalar(@cups);

                last;

            }

        }


    }



    my $one;


    for (my $i=0;$i<@cups;$i++) {

        if ($cups[$i]==1) {

            $one=$i;
            last;

        }

    }


    my $out="";


    for (1..$#cups) {

        $one++;

        $one=0 if $one>=@cups;

        $out .= $cups[$one];

    }


    return $out;

}



my $p1=play_part1(\@cups);



# ------------------------------------------------------------
# Part 2
# ------------------------------------------------------------

sub play_part2 {


    my ($initial)=@_;


    my $max_label=1000000;
    my $moves=10000000;


    my @next=(0)x($max_label+1);



    my $prev=$initial->[0];


    for (my $i=1;$i<@$initial;$i++) {

        $next[$prev]=$initial->[$i];

        $prev=$initial->[$i];

    }



    for (my $x=@$initial+1;$x<=$max_label;$x++) {

        $next[$prev]=$x;

        $prev=$x;

    }


    $next[$prev]=$initial->[0];



    my $current=$initial->[0];



    for (1..$moves) {


        my $a=$next[$current];

        my $b=$next[$a];

        my $c=$next[$b];


        # remove three cups

        $next[$current]=$next[$c];



        my $dest=$current-1;

        $dest=$max_label if $dest==0;



        while ($dest==$a ||
               $dest==$b ||
               $dest==$c) {


            $dest--;

            $dest=$max_label if $dest==0;

        }



        # insert cups

        $next[$c]=$next[$dest];

        $next[$dest]=$a;



        $current=$next[$current];

    }



    return $next[1] * $next[$next[1]];

}



my $p2=play_part2(\@cups);



print "2020 day23: pl_ans_1: $p1\n";
print "2020 day23: pl_ans_2: $p2\n";

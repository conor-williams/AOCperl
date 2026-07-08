#!/usr/bin/perl
use strict;
use warnings;

sub parse {
    my ($data)=@_;

    my @bricks;

    for my $line (split /\n/,$data) {

        my ($a,$b)=split /~/,$line;

        my @a=map {int($_)} split /,/,$a;
        my @b=map {int($_)} split /,/,$b;

        push @bricks, [
            $a[0]<$b[0]?$a[0]:$b[0],
            $a[0]>$b[0]?$a[0]:$b[0],
            $a[1]<$b[1]?$a[1]:$b[1],
            $a[1]>$b[1]?$a[1]:$b[1],
            $a[2]<$b[2]?$a[2]:$b[2],
            $a[2]>$b[2]?$a[2]:$b[2]
        ];
    }

    return @bricks;
}

sub settle {
    my (@bricks)=@_;

    @bricks=sort {$a->[4] <=> $b->[4]} @bricks;

    my @settled;

    for my $b (@bricks) {

        my ($x1,$x2,$y1,$y2,$z1,$z2)=@$b;

        my $highest=0;

        for my $s (@settled) {

            my ($sx1,$sx2,$sy1,$sy2,$sz1,$sz2)=@$s;

            my $overlap =
                !($x2<$sx1 || $sx2<$x1 ||
                  $y2<$sy1 || $sy2<$y1);

            $highest=$sz2 if $overlap && $sz2>$highest;
        }

        my $height=$z2-$z1;

        push @settled, [
            $x1,$x2,$y1,$y2,
            $highest+1,
            $highest+1+$height
        ];
    }

    return @settled;
}

sub build_graph {
    my (@bricks)=@_;

    my $n=@bricks;

    my @supports=map {{} } (1..$n);
    my @supported_by=map {{} } (1..$n);

    for my $i (0..$n-1) {

        my ($x1,$x2,$y1,$y2,$z1,$z2)=@{$bricks[$i]};

        for my $j (0..$n-1) {

            next if $i==$j;

            my ($xx1,$xx2,$yy1,$yy2,$zz1,$zz2)=@{$bricks[$j]};

            next unless $zz1==$z2+1;

            my $overlap =
                !($x2<$xx1 || $xx2<$x1 ||
                  $y2<$yy1 || $yy2<$y1);

            if ($overlap) {
                $supports[$i]{$j}=1;
                $supported_by[$j]{$i}=1;
            }
        }
    }

    return (\@supports,\@supported_by);
}

sub part1 {
    my (@bricks)=@_;

    my ($supports,$supported_by)=build_graph(@bricks);

    my $ans=0;

    for my $i (0..$#bricks) {

        my $safe=1;

        for my $above (keys %{$supports->[$i]}) {

            if (keys %{$supported_by->[$above]} == 1) {
                $safe=0;
                last;
            }
        }

        $ans++ if $safe;
    }

    return $ans;
}

sub part2 {
    my (@bricks)=@_;

    my ($supports,$supported_by)=build_graph(@bricks);

    my $total=0;

    for my $start (0..$#bricks) {

        my %falling=($start=>1);

        my @q=($start);
        my $head=0;

        while ($head<@q) {

            my $b=$q[$head++];

            for my $above (keys %{$supports->[$b]}) {

                next if exists $falling{$above};

                my $ok=1;

                for my $s (keys %{$supported_by->[$above]}) {
                    $ok=0 unless exists $falling{$s};
                }

                if ($ok) {
                    $falling{$above}=1;
                    push @q,$above;
                }
            }
        }

        $total += scalar(keys %falling)-1;
    }

    return $total;
}

sub main {

    open my $fh,"<",$ARGV[0] or die $!;

    local $/;
    my $data=<$fh>;

    close $fh;

    my @bricks=settle(parse($data));

    print "2023 day22: pl_ans_1: ",part1(@bricks),"\n";
    print "2023 day22: pl_ans_2: ",part2(@bricks),"\n";
}

main();

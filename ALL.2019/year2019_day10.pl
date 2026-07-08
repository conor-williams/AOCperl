#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(floor);
use Math::Trig qw(pi);


# ============================
# Parse
# ============================

sub parse {
    my (@grid) = @_;

    my @asteroids;

    for my $y (0 .. $#grid) {
        my @row = split //, $grid[$y];

        for my $x (0 .. $#row) {
            if ($row[$x] eq "#") {
                push @asteroids, [$x, $y];
            }
        }
    }

    return @asteroids;
}


# ============================
# gcd
# ============================

sub gcd {
    my ($a,$b)=@_;

    $a = abs($a);
    $b = abs($b);

    while ($b != 0) {
        ($a,$b)=($b,$a % $b);
    }

    return $a;
}


# ============================
# Visible count
# ============================

sub visible_count {

    my ($ax,$ay,@asteroids)=@_;

    my %seen;


    for my $a (@asteroids) {

        my ($bx,$by)=@$a;

        next if $bx == $ax && $by == $ay;


        my $dx=$bx-$ax;
        my $dy=$by-$ay;


        my $g=gcd(abs($dx),abs($dy));


        $seen{
            ($dx/$g).",".($dy/$g)
        }=1;
    }


    return scalar keys %seen;
}


# ============================
# Angle
# ============================

sub angle {

    my ($ax,$ay,$bx,$by)=@_;

    my $dx=$bx-$ax;
    my $dy=$by-$ay;


    # same as python:
    # atan2(dx,-dy)

    my $ang = atan2($dx,-$dy);


    $ang += 2*pi if $ang < 0;


    return $ang;
}



# ============================
# Main
# ============================


my $file = shift @ARGV;

open my $fh,"<",$file or die $!;


my @grid;

while (<$fh>) {
    chomp;
    push @grid,$_;
}

close $fh;



my @asteroids=parse(@grid);



# ----------------------------
# Part 1
# ----------------------------


my $best=0;
my @best_pos;


for my $a (@asteroids) {

    my ($x,$y)=@$a;

    my $count=
        visible_count($x,$y,@asteroids);


    if ($count > $best) {

        $best=$count;

        @best_pos=($x,$y);
    }
}


my $p1=$best;



# ----------------------------
# Part 2
# ----------------------------


my ($ax,$ay)=@best_pos;


my %groups;


for my $a (@asteroids) {

    my ($bx,$by)=@$a;


    next if $bx==$ax && $by==$ay;


    my $ang =
        angle($ax,$ay,$bx,$by);


    my $dist =
        ($bx-$ax)**2 +
        ($by-$ay)**2;


    push @{$groups{$ang}},
        [$dist,$bx,$by];
}



# sort every angle group by distance

for my $ang (keys %groups) {

    my @sorted =
        sort {
            $a->[0] <=> $b->[0]
        }
        @{$groups{$ang}};


    $groups{$ang}=\@sorted;
}



# sort angles clockwise

my @order =
    sort {$a <=> $b}
    keys %groups;



my $vaporized=0;

my ($rx,$ry);



while (1) {

    my $removed=0;


    for my $ang (@order) {


        next unless @{$groups{$ang}};


        $removed=1;


        my $item =
            shift @{$groups{$ang}};


        my ($d,$x,$y)=@$item;


        $vaporized++;


        if ($vaporized == 200) {

            ($rx,$ry)=($x,$y);

            last;
        }
    }


    last if defined $rx;


    last unless $removed;
}



my $p2 =
    $rx * 100 + $ry;



print "2019 day10: pl_ans_1: $p1\n";
print "2019 day10: pl_ans_2: $p2\n";

#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh,"<",$file) or die $!;
my @lines = <$fh>;
close($fh);

chomp @lines;

my @sensors;

foreach my $line (@lines) {

    my @n = ($line =~ /-?\d+/g);

    my ($sx,$sy,$bx,$by)=@n;

    my $dist = abs($sx-$bx)+abs($sy-$by);

    push @sensors, [$sx,$sy,$dist,$bx,$by];
}

sub merge {

    my @ints = sort {$a->[0] <=> $b->[0]} @_;

    my @merged;

    foreach my $i (@ints) {

        if (!@merged || $i->[0] > $merged[-1][1]+1) {

            push @merged, [$i->[0],$i->[1]];

        } else {

            $merged[-1][1]=$i->[1]
                if $i->[1] > $merged[-1][1];

        }
    }

    return @merged;
}

sub part1 {

    my ($target)=@_;

    my @intervals;

    foreach my $s (@sensors) {

        my ($sx,$sy,$dist,$bx,$by)=@$s;

        my $dy = abs($sy-$target);

        my $rem = $dist-$dy;

        next if $rem<0;

        push @intervals, [$sx-$rem,$sx+$rem];
    }

    my @merged = merge(@intervals);

    my $total=0;

    foreach my $m (@merged) {

        $total += $m->[1]-$m->[0]+1;

    }

    my %beacons;

    foreach my $s (@sensors) {

        my ($sx,$sy,$dist,$bx,$by)=@$s;

        $beacons{$bx}=1 if $by==$target;

    }

    foreach my $b (keys %beacons) {

        foreach my $m (@merged) {

            if ($b >= $m->[0] && $b <= $m->[1]) {

                $total--;

                last;

            }

        }

    }

    return $total;

}

sub part2 {

    my ($limit)=@_;

    for my $y (0..$limit) {

        my @intervals;

        foreach my $s (@sensors) {

            my ($sx,$sy,$dist)=@$s;

            my $dy = abs($sy-$y);

            my $rem = $dist-$dy;

            next if $rem<0;

            push @intervals, [$sx-$rem,$sx+$rem];

        }

        my @merged = merge(@intervals);

        my $x=0;

        foreach my $m (@merged) {

            if ($x < $m->[0]) {

                return $x*4000000+$y;

            }

            $x = $m->[1]+1 if $m->[1]+1 > $x;

            last if $x>$limit;

        }

    }

    return undef;

}

print "2022 day15: pl_ans_1:  ", part1(2_000_000), "\n";
print "2022 day15: pl_ans_2:  ", part2(4_000_000), "\n";

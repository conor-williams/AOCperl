#!/usr/bin/perl
use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my %dots;
my @folds;

while (<$fh>) {
    chomp;

    next if $_ eq "" && !@folds;

    if (/^(\d+),(\d+)$/) {
        my ($x,$y)=($1,$2);
        $dots{"$x,$y"} = 1;
    }
    elsif (/^fold along ([xy])=(\d+)$/) {
        push @folds, [$1,int($2)];
    }
}

close $fh;



# -------------------------
# perform fold
# -------------------------

sub do_fold {
    my ($dots,$axis,$line)=@_;

    my %new;


    foreach my $key (keys %$dots) {

        my ($x,$y)=split /,/, $key;

        if ($axis eq "x" && $x > $line) {
            $x = $line - ($x - $line);
        }

        if ($axis eq "y" && $y > $line) {
            $y = $line - ($y - $line);
        }

        $new{"$x,$y"}=1;
    }


    return \%new;
}



# -------------------------
# part 1
# -------------------------

my $first = 1;
my $ans1;

for my $fold (@folds) {

    my $new_dots = do_fold(
        \%dots,
        $fold->[0],
        $fold->[1]
    );

    %dots = %$new_dots;

    if ($first) {
        $ans1 = scalar keys %dots;
        $first = 0;
    }
}


print "2021 day13: pl_ans_1: $ans1\n";



# -------------------------
# part 2 drawing
# -------------------------

my ($max_x,$max_y)=(0,0);

for my $key (keys %dots) {

    my ($x,$y)=split /,/, $key;

    $max_x=$x if $x>$max_x;
    $max_y=$y if $y>$max_y;
}


print "2021 day13: pl_ans_2:\n";


for my $y (0..$max_y) {

    my $line="";

    for my $x (0..$max_x) {

        if (exists $dots{"$x,$y"}) {
            $line .= "#";
        }
        else {
            $line .= " ";
        }
    }

    print "$line \n";
}

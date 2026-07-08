#!/usr/bin/perl
use strict;
use warnings;
no warnings 'recursion';

my $file = $ARGV[0];

open my $fh, "<", $file or die "$file: $!";
my $text = do { local $/; <$fh> };
close $fh;

# -----------------------------
# Parse input
# -----------------------------

my %tiles;

for my $block (split /\n\n/, $text) {

    my @lines = split /\n/, $block;

    my ($id) = $lines[0] =~ /Tile (\d+):/;

    my @grid = @lines[1..$#lines];

    $tiles{$id} = \@grid;
}


# -----------------------------
# Tile helpers
# -----------------------------

sub rotate {
    my ($g) = @_;

    my $h = scalar @$g;
    my $w = length($g->[0]);

    my @out;

    for my $x (0 .. $w-1) {
        my $row = "";

        for my $y (reverse 0 .. $h-1) {
            $row .= substr($g->[$y], $x, 1);
        }

        push @out, $row;
    }

    return \@out;
}


sub flip {
    my ($g) = @_;

    return [
        map { scalar reverse $_ } @$g
    ];
}


sub orientations {
    my ($g)=@_;

    my @out;

    my $x=$g;

    for (1..4) {
        push @out,$x;
        push @out,flip($x);
        $x=rotate($x);
    }

    return @out;
}


sub edges {
    my ($g)=@_;

    my $top=$g->[0];
    my $bottom=$g->[-1];

    my $left="";
    my $right="";

    for my $r (@$g) {
        $left.=substr($r,0,1);
        $right.=substr($r,-1,1);
    }

    return ($top,$right,$bottom,$left);
}


sub canonical {
    my ($s)=@_;

    my $r=reverse $s;

    return $s lt $r ? $s : $r;
}


# -----------------------------
# Part 1 corner detection
# -----------------------------

my %edge_count;

for my $id (keys %tiles) {

    my @e=edges($tiles{$id});

    for my $x (@e) {
        $edge_count{canonical($x)}++;
    }
}


my $part1=1;

for my $id (keys %tiles) {

    my @e=edges($tiles{$id});

    my $unique=0;

    for my $x (@e) {
        $unique++ if $edge_count{canonical($x)} == 1;
    }

    if ($unique==2) {
        $part1 *= $id;
    }
}


print "2020 day20: pl_ans_1: $part1\n";


# -----------------------------
# Assemble image
# -----------------------------

my $size = int(sqrt(keys %tiles));

my %used;
my @board;


sub match_tile {

    my ($pos,$grid)=@_;

    my $row=int($pos/$size);
    my $col=$pos%$size;


    if ($row>0) {

        my $above=$board[$row-1][$col];

        my $bottom=(edges($above))[2];

        return 0 if $grid->[0] ne $bottom;
    }


    if ($col>0) {

        my $left=$board[$row][$col-1];

        my $right=(edges($left))[1];

        my $this_left=(edges($grid))[3];

        return 0 if $this_left ne $right;
    }

    return 1;
}


sub solve_tiles {

    my ($pos)=@_;

    return 1 if $pos==$size*$size;


    for my $id (keys %tiles) {

        next if $used{$id};


        for my $g (orientations($tiles{$id})) {

            next unless match_tile($pos,$g);


            my $r=int($pos/$size);
            my $c=$pos%$size;

            $board[$r][$c]=$g;
            $used{$id}=1;


            return 1 if solve_tiles($pos+1);


            delete $used{$id};
        }
    }

    return 0;
}


solve_tiles(0);


# -----------------------------
# Remove borders
# -----------------------------

my @image;

for my $tr (0..$size-1) {

    for my $inner (1..8) {

        my $row="";

        for my $tc (0..$size-1) {

            my $tile=$board[$tr][$tc];

            $row .= substr($tile->[$inner],1,8);
        }

        push @image,$row;
    }
}


# -----------------------------
# Sea monsters
# -----------------------------

my @monster = (
    [18,0],
    [0,1],[5,1],[6,1],[11,1],[12,1],[17,1],[18,1],[19,1],
    [1,2],[4,2],[7,2],[10,2],[13,2],[16,2]
);


sub monsters {

    my ($img)=@_;

    my $h=@$img;
    my $w=length($img->[0]);

    my $count=0;


    for my $y (0..$h-3) {

        for my $x (0..$w-20) {

            my $ok=1;

            for my $p (@monster) {

                my ($dx,$dy)=@$p;

                if (substr($img->[$y+$dy],$x+$dx,1) ne "#") {
                    $ok=0;
                    last;
                }
            }

            $count++ if $ok;
        }
    }

    return $count;
}


my $best=0;

for my $g (orientations(\@image)) {

    my $m=monsters($g);

    $best=$m if $m>$best;
}


my $hashes=0;

for my $r (@image) {
    $hashes += () = $r =~ /#/g;
}


my $part2=$hashes - ($best*15);


print "2020 day20: pl_ans_2: $part2\n";

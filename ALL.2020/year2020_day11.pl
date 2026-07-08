#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @grid;

while (<$fh>) {
    chomp;
    next unless length;
    push @grid, [ split // ];
}

close($fh);

sub step {
    my ($grid, $mode) = @_;

    my $h = scalar(@$grid);
    my $w = scalar(@{$grid->[0]});

    my @new = map { [ @$_ ] } @$grid;

    my @dirs = (
        [-1,-1],[-1,0],[-1,1],
        [0,-1],        [0,1],
        [1,-1],[1,0],[1,1]
    );

    for my $y (0 .. $h-1) {
        for my $x (0 .. $w-1) {

            next if $grid->[$y][$x] eq '.';

            my $adj = 0;

            foreach my $d (@dirs) {

                my ($dx,$dy)=@$d;
                my $nx=$x+$dx;
                my $ny=$y+$dy;

                if($mode==1){

                    next if $nx<0 || $ny<0 || $nx>=$w || $ny>=$h;

                    $adj++ if $grid->[$ny][$nx] eq '#';

                }else{

                    while($nx>=0 && $ny>=0 && $nx<$w && $ny<$h){

                        if($grid->[$ny][$nx] ne '.'){

                            $adj++ if $grid->[$ny][$nx] eq '#';
                            last;
                        }

                        $nx += $dx;
                        $ny += $dy;
                    }
                }
            }

            my $limit = ($mode==1) ? 4 : 5;

            if($grid->[$y][$x] eq 'L' && $adj==0){
                $new[$y][$x]='#';
            }
            elsif($grid->[$y][$x] eq '#' && $adj >= $limit){
                $new[$y][$x]='L';
            }
        }
    }

    return \@new;
}

sub solve {
    my ($grid,$mode)=@_;

    while(1){

        my $next = step($grid,$mode);

        my $same = 1;

        OUT:
        for my $y (0..$#$grid){
            for my $x (0..$#{$grid->[$y]}){
                if($grid->[$y][$x] ne $next->[$y][$x]){
                    $same=0;
                    last OUT;
                }
            }
        }

        if($same){

            my $count=0;

            foreach my $row (@$grid){
                foreach my $c (@$row){
                    $count++ if $c eq '#';
                }
            }

            return $count;
        }

        $grid = $next;
    }
}

my @copy = map { [ @$_ ] } @grid;

my $p1 = solve(\@grid,1);
my $p2 = solve(\@copy,2);

print "2020 day11: pl_ans_1: $p1\n";
print "2020 day11: pl_ans_2: $p2\n";

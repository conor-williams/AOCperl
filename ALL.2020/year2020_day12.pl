#!/usr/bin/perl
use strict;
use warnings;

sub rotate {
    my ($wx, $wy, $angle) = @_;

    $angle %= 360;

    return ($wx, $wy)     if $angle == 0;
    return ($wy, -$wx)    if $angle == 90;
    return (-$wx, -$wy)   if $angle == 180;
    return (-$wy, $wx)    if $angle == 270;
}

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @cmds;

while (<$fh>) {
    chomp;
    next unless length;

    push @cmds, [ substr($_,0,1), int(substr($_,1)) ];
}

close($fh);

# ---------------- Part 1 ----------------

my ($x,$y) = (0,0);

my $dir = 0;        # 0E 1S 2W 3N

my @dirs = (
    [1,0],
    [0,-1],
    [-1,0],
    [0,1]
);

foreach my $cmd (@cmds){

    my ($c,$v)=@$cmd;

    if($c eq 'N'){
        $y += $v;
    }
    elsif($c eq 'S'){
        $y -= $v;
    }
    elsif($c eq 'E'){
        $x += $v;
    }
    elsif($c eq 'W'){
        $x -= $v;
    }
    elsif($c eq 'L'){
        $dir = ($dir - $v/90) % 4;
    }
    elsif($c eq 'R'){
        $dir = ($dir + $v/90) % 4;
    }
    elsif($c eq 'F'){
        my ($dx,$dy)=@{$dirs[$dir]};
        $x += $dx*$v;
        $y += $dy*$v;
    }
}

my $p1 = abs($x)+abs($y);

# ---------------- Part 2 ----------------

my ($sx,$sy)=(0,0);
my ($wx,$wy)=(10,1);

foreach my $cmd (@cmds){

    my ($c,$v)=@$cmd;

    if($c eq 'N'){
        $wy += $v;
    }
    elsif($c eq 'S'){
        $wy -= $v;
    }
    elsif($c eq 'E'){
        $wx += $v;
    }
    elsif($c eq 'W'){
        $wx -= $v;
    }
    elsif($c eq 'L'){
        ($wx,$wy)=rotate($wx,$wy,360-$v);
    }
    elsif($c eq 'R'){
        ($wx,$wy)=rotate($wx,$wy,$v);
    }
    elsif($c eq 'F'){
        $sx += $wx*$v;
        $sy += $wy*$v;
    }
}

my $p2 = abs($sx)+abs($sy);

print "2020 day12: pl_ans_1: $p1\n";
print "2020 day12: pl_ans_2: $p2\n";

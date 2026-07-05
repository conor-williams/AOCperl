#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(min max);
use POSIX qw(ceil);
use List::Util qw(sum0);

my @boss = do {
    open my $fh, '<', $ARGV[0] or die $!;
    my $t = do { local $/; <$fh> };
    ($t =~ /(\d+)/g);
};

my ($boss_hp, $boss_damage, $boss_armor) = @boss;
my $player_hp = 100;

my @weapons = (
    [8, 4, 0],
    [10, 5, 0],
    [25, 6, 0],
    [40, 7, 0],
    [74, 8, 0],
);

my @armors = (
    [0, 0, 0],
    [13, 0, 1],
    [31, 0, 2],
    [53, 0, 3],
    [75, 0, 4],
    [102, 0, 5],
);

my @rings = (
    [0, 0, 0],
    [0, 0, 0],
    [25, 1, 0],
    [50, 2, 0],
    [100, 3, 0],
    [20, 0, 1],
    [40, 0, 2],
    [80, 0, 3],
);

sub player_wins {
    my ($dmg, $arm) = @_;

    my $player_hit = max(1, $dmg - $boss_armor);
    my $boss_hit   = max(1, $boss_damage - $arm);

    my $boss_turns   = ceil($boss_hp / $player_hit);
    my $player_turns = ceil($player_hp / $boss_hit);

    return $boss_turns <= $player_turns;
}

my $best  = 1e18;
my $worst = 0;

for my $w (@weapons) {
for my $a (@armors) {

    for my $i (0 .. $#rings) {
    for my $j ($i+1 .. $#rings) {

        my $cost = $w->[0] + $a->[0] + $rings[$i][0] + $rings[$j][0];
        my $dmg  = $w->[1] + $a->[1] + $rings[$i][1] + $rings[$j][1];
        my $arm  = $w->[2] + $a->[2] + $rings[$i][2] + $rings[$j][2];

        if (player_wins($dmg, $arm)) {
            $best = min($best, $cost);
        } else {
            $worst = max($worst, $cost);
        }
    }}
}}

print "2015 day21: pl_ans_1: $best\n";
print "2015 day21: pl_ans_2: $worst\n";

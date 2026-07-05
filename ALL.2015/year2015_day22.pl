#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min);

my ($boss_hp_init, $boss_dmg);

open my $fh, "<", $ARGV[0] or die $!;
while (<$fh>) {
    $boss_hp_init = $1 if /Hit Points:\s*(\d+)/;
    $boss_dmg     = $1 if /Damage:\s*(\d+)/;
}

my %cost = (
    M => 53,
    D => 73,
    S => 113,
    P => 173,
    R => 229,
);

# ----------------------------
# EXACT Python sim translation
# ----------------------------
sub sim {
    my ($actions_ref, $part) = @_;

    my @actions = @$actions_ref;

    my $hp = 50;
    my $mana = 500;
    my $armor = 0;

    my $turn_c = 0;
    my $mana_spent = 0;

    my $poison = 0;
    my $shield = 0;
    my $recharge = 0;

    my $boss_hp = $boss_hp_init;   # IMPORTANT FIX

    my $my_turn = 1;

    while (1) {

        return 0 if $turn_c > $#actions;

        # effects
        if ($poison > 0) {
            $poison--;
            $boss_hp -= 3;
        }

        if ($shield > 0) {
            $shield--;
            $armor = 7;
        } else {
            $armor = 0;
        }

        if ($recharge > 0) {
            $recharge--;
            $mana += 101;
        }

        if ($my_turn == 1) {

            if ($part == 2) {
                $hp--;
                return 0 if $hp <= 0;
            }

            my $action = $actions[$turn_c];

            $mana -= $cost{$action};
            $mana_spent += $cost{$action};

            if ($action eq 'M') {
                $boss_hp -= 4;
            }
            elsif ($action eq 'D') {
                $boss_hp -= 2;
                $hp += 2;
            }
            elsif ($action eq 'S') {
                return 0 if $shield > 0;
                $shield = 6;
            }
            elsif ($action eq 'P') {
                return 0 if $poison > 0;
                $poison = 6;
            }
            elsif ($action eq 'R') {
                return 0 if $recharge > 0;
                $recharge = 5;
            }

            return 0 if $mana < 0;
        }

        return $mana_spent if $boss_hp <= 0;

        if ($my_turn == -1) {
            my $dmg = $boss_dmg - $armor;
            $dmg = 1 if $dmg < 1;
            $hp -= $dmg;
            return 0 if $hp <= 0;
        }

        if ($my_turn == 1) {
            $turn_c++;
        }

        $my_turn *= -1;
    }
}

# ----------------------------
# iterate_actions (unchanged logic)
# ----------------------------
sub iterate_actions {
    my ($a, $pos) = @_;

    my %next = (
        M => 'D',
        D => 'S',
        S => 'P',
        P => 'R',
        R => 'M'
    );

    $a->[$pos] = $next{$a->[$pos]};

    if ($a->[$pos] eq 'M') {
        if ($pos + 1 <= $#$a) {
            iterate_actions($a, $pos + 1);
        }
    }
}

# ----------------------------
# main
# ----------------------------
for my $part (1, 2) {

    my @actions = ('M') x 20;

    my $min = 1_000_000;

    for (1 .. 1_000_000) {

        my $r = sim(\@actions, $part);

        if ($r) {
            $min = $r if $r < $min;
        }

        iterate_actions(\@actions, 0);
    }

    print "2015 day22: pl_ans_$part: $min\n";
}

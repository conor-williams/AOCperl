#!/usr/bin/perl
use strict;
use warnings;

sub main {
    my ($path) = @ARGV;

    my $total_p1 = 0;
    my $total_p2 = 0;

    open my $fh, "<", $path or die "Cannot open $path: $!";

    while (<$fh>) {
        chomp;
        next if /^\s*$/;

        my $line = $_;

        # Game X: 3 red, 4 blue; ...
        my ($game_part, $sets_part) = split /:/, $line;

        my ($game_id) = $game_part =~ /Game\s+(\d+)/;

        my @rounds = split /;/, $sets_part;

        my $max_r = 0;
        my $max_g = 0;
        my $max_b = 0;

        my $possible = 1;

        for my $r (@rounds) {
            my @cubes = split /,/, $r;

            for my $c (@cubes) {
                $c =~ s/^\s+|\s+$//g;
                next if $c eq "";

                my ($num, $color) = split /\s+/, $c;
                $num = int($num);

                if ($color eq "red") {
                    $max_r = $num if $num > $max_r;
                    $possible = 0 if $num > 12;
                }
                elsif ($color eq "green") {
                    $max_g = $num if $num > $max_g;
                    $possible = 0 if $num > 13;
                }
                elsif ($color eq "blue") {
                    $max_b = $num if $num > $max_b;
                    $possible = 0 if $num > 14;
                }
            }
        }

        # Part 1
        $total_p1 += $game_id if $possible;

        # Part 2
        $total_p2 += $max_r * $max_g * $max_b;
    }

    close $fh;

    print "2023 day2: pl_ans_1: $total_p1\n";
    print "2023 day2: pl_ans_2: $total_p2\n";
}

main();

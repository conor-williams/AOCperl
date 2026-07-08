#!/usr/bin/perl
use strict;
use warnings;

sub neighbors {
    my ($x, $y, $w, $h) = @_;

    my @result;

    for my $dy (-1, 0, 1) {
        for my $dx (-1, 0, 1) {
            next if $dx == 0 && $dy == 0;

            my $nx = $x + $dx;
            my $ny = $y + $dy;

            if (0 <= $nx && $nx < $w && 0 <= $ny && $ny < $h) {
                push @result, [$nx, $ny];
            }
        }
    }

    return @result;
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @grid;
    while (<$fh>) {
        chomp;
        push @grid, $_ if /\S/;
    }
    close $fh;

    my $h = scalar @grid;
    my $w = length($grid[0]);

    my @part_numbers;
    my %gear_map;

    for my $y (0 .. $h - 1) {
        my $x = 0;

        while ($x < $w) {

            if (substr($grid[$y], $x, 1) =~ /\d/) {

                my $num = "";
                my @cells;

                while ($x < $w && substr($grid[$y], $x, 1) =~ /\d/) {
                    $num .= substr($grid[$y], $x, 1);
                    push @cells, [$x, $y];
                    $x++;
                }

                $num = int($num);

                my $is_part = 0;
                my %gears;

                for my $cell (@cells) {
                    my ($cx, $cy) = @$cell;

                    for my $n (neighbors($cx, $cy, $w, $h)) {
                        my ($nx, $ny) = @$n;
                        my $c = substr($grid[$ny], $nx, 1);

                        if ($c !~ /\d/ && $c ne ".") {
                            $is_part = 1;
                        }

                        if ($c eq "*") {
                            $gears{"$nx,$ny"} = 1;
                        }
                    }
                }

                push @part_numbers, $num if $is_part;

                for my $g (keys %gears) {
                    push @{ $gear_map{$g} }, $num;
                }

            } else {
                $x++;
            }
        }
    }

    my $p1 = 0;
    $p1 += $_ for @part_numbers;

    my $p2 = 0;

    for my $g (keys %gear_map) {
        my @nums = @{ $gear_map{$g} };

        if (@nums == 2) {
            $p2 += $nums[0] * $nums[1];
        }
    }

    print "2023 day3: pl_ans_1: $p1\n";
    print "2023 day3: pl_ans_2: $p2\n";
}

main();

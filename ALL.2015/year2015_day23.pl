#!/usr/bin/env perl

use strict;
use warnings;

open my $fh, '<', $ARGV[0] or die $!;
my @p = map { chomp; [split] } <$fh>;
close $fh;

sub run {
    my ($a) = @_;

    my %r = (a => $a, b => 0);
    my $i = 0;

    while ($i >= 0 && $i < @p) {

        my $op = $p[$i][0];

        if ($op eq 'hlf') {
            $r{$p[$i][1]} = int($r{$p[$i][1]} / 2);
            $i++;
        }
        elsif ($op eq 'tpl') {
            $r{$p[$i][1]} *= 3;
            $i++;
        }
        elsif ($op eq 'inc') {
            $r{$p[$i][1]}++;
            $i++;
        }
        elsif ($op eq 'jmp') {
            $i += $p[$i][1];
        }
        elsif ($op eq 'jie') {
            my $x = substr($p[$i][1], 0, 1);
            $i += ($r{$x} % 2 == 0) ? $p[$i][2] : 1;
        }
        elsif ($op eq 'jio') {
            my $x = substr($p[$i][1], 0, 1);
            $i += ($r{$x} == 1) ? $p[$i][2] : 1;
        }
    }

    return $r{b};
}

print "2015 day23: pl_ans_1: ", run(0), "\n";
print "2015 day23: pl_ans_2: ", run(1), "\n";

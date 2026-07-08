#!/usr/bin/perl

use strict;
use warnings;

sub run {

    my ($program,$input_value) = @_;

    my @mem = @$program;

    my $ip = 0;

    my $output;

    while (1) {

        my $instr = $mem[$ip];

        my $opcode = $instr % 100;
        my $m1 = int($instr / 100) % 10;
        my $m2 = int($instr / 1000) % 10;
        my $m3 = int($instr / 10000) % 10;

        if ($opcode == 99) {
            return $output;
        }

        if ($opcode == 1 || $opcode == 2) {

            my $a = $m1 ? $mem[$ip+1] : $mem[$mem[$ip+1]];
            my $b = $m2 ? $mem[$ip+2] : $mem[$mem[$ip+2]];

            my $dest = $mem[$ip+3];

            if ($opcode == 1) {
                $mem[$dest] = $a + $b;
            }
            else {
                $mem[$dest] = $a * $b;
            }

            $ip += 4;
        }

        elsif ($opcode == 3) {

            $mem[$mem[$ip+1]] = $input_value;

            $ip += 2;
        }

        elsif ($opcode == 4) {

            $output = $m1
                ? $mem[$ip+1]
                : $mem[$mem[$ip+1]];

            $ip += 2;
        }

        elsif ($opcode == 5) {

            my $a = $m1 ? $mem[$ip+1] : $mem[$mem[$ip+1]];
            my $b = $m2 ? $mem[$ip+2] : $mem[$mem[$ip+2]];

            if ($a != 0) {
                $ip = $b;
            }
            else {
                $ip += 3;
            }
        }

        elsif ($opcode == 6) {

            my $a = $m1 ? $mem[$ip+1] : $mem[$mem[$ip+1]];
            my $b = $m2 ? $mem[$ip+2] : $mem[$mem[$ip+2]];

            if ($a == 0) {
                $ip = $b;
            }
            else {
                $ip += 3;
            }
        }

        elsif ($opcode == 7) {

            my $a = $m1 ? $mem[$ip+1] : $mem[$mem[$ip+1]];
            my $b = $m2 ? $mem[$ip+2] : $mem[$mem[$ip+2]];

            $mem[$mem[$ip+3]] =
                ($a < $b) ? 1 : 0;

            $ip += 4;
        }

        elsif ($opcode == 8) {

            my $a = $m1 ? $mem[$ip+1] : $mem[$mem[$ip+1]];
            my $b = $m2 ? $mem[$ip+2] : $mem[$mem[$ip+2]];

            $mem[$mem[$ip+3]] =
                ($a == $b) ? 1 : 0;

            $ip += 4;
        }
    }
}


sub main {

    my $path = $ARGV[0];

    open my $fh,'<',$path or die $!;

    chomp(my $line = <$fh>);

    close $fh;

    my @program =
        map { int($_) }
        split /,/,$line;

    my $p1 = run(\@program,1);

    my $p2 = run(\@program,5);

    print "2019 day5: pl_ans_1: $p1\n";
    print "2019 day5: pl_ans_2: $p2\n";
}


main();

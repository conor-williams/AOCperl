#!/usr/bin/perl

use strict;
use warnings;

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines;

    while (<$fh>) {
        chomp;
        next if $_ eq "";
        push @lines, $_;
    }

    close($fh);

    my %regs;

    my $highest_ever = 0;

    foreach my $line (@lines) {

        my ($r1, $op, $amt, undef, $r2, $cond, $val) = split(/\s+/, $line);

        $amt = int($amt);
        $val = int($val);

        $regs{$r1} //= 0;
        $regs{$r2} //= 0;

        my $ok = 0;

        if    ($cond eq ">")  { $ok = ($regs{$r2} >  $val); }
        elsif ($cond eq "<")  { $ok = ($regs{$r2} <  $val); }
        elsif ($cond eq ">=") { $ok = ($regs{$r2} >= $val); }
        elsif ($cond eq "<=") { $ok = ($regs{$r2} <= $val); }
        elsif ($cond eq "==") { $ok = ($regs{$r2} == $val); }
        elsif ($cond eq "!=") { $ok = ($regs{$r2} != $val); }

        if ($ok) {

            if ($op eq "inc") {
                $regs{$r1} += $amt;
            }
            else {
                $regs{$r1} -= $amt;
            }

            my $mx = 0;
            foreach my $v (values %regs) {
                $mx = $v if $v > $mx;
            }

            $highest_ever = $mx if $mx > $highest_ever;
        }
    }

    my $p1 = 0;

    if (%regs) {
        ($p1) = sort { $b <=> $a } values %regs;
    }

    print "2017 day8: pl_ans_1: $p1\n";
    print "2017 day8: pl_ans_2: $highest_ever\n";
}

main();

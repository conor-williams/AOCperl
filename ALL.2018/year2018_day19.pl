#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Parse input
# -------------------------------------------------

sub parse
{
    my ($text) = @_;

    my @lines = grep { $_ ne '' } split(/\n/, $text);


    my ($ip_reg) = $lines[0] =~ /(\d+)/;


    my @prog;


    for my $i (1 .. $#lines)
    {
        my ($op, $a, $b, $c) =
            split(/\s+/, $lines[$i]);

        push @prog,
        [
            $op,
            int($a),
            int($b),
            int($c)
        ];
    }


    return ($ip_reg, \@prog);
}


# -------------------------------------------------
# Run program
# -------------------------------------------------

sub run
{
    my ($ip_reg, $prog, $r0, $limit) = @_;


    $r0 = 0 unless defined $r0;


    my @r = (0,0,0,0,0,0);

    $r[0] = $r0;


    my $ip = 0;
    my $steps = 0;


    while ($ip >= 0 && $ip < @$prog)
    {
        last if defined($limit) && $steps >= $limit;


        $r[$ip_reg] = $ip;


        my ($op, $a, $b, $c) =
            @{$prog->[$ip]};


        if ($op eq "addr")
        {
            $r[$c] = $r[$a] + $r[$b];
        }
        elsif ($op eq "addi")
        {
            $r[$c] = $r[$a] + $b;
        }
        elsif ($op eq "mulr")
        {
            $r[$c] = $r[$a] * $r[$b];
        }
        elsif ($op eq "muli")
        {
            $r[$c] = $r[$a] * $b;
        }
        elsif ($op eq "banr")
        {
            $r[$c] = $r[$a] & $r[$b];
        }
        elsif ($op eq "bani")
        {
            $r[$c] = $r[$a] & $b;
        }
        elsif ($op eq "borr")
        {
            $r[$c] = $r[$a] | $r[$b];
        }
        elsif ($op eq "bori")
        {
            $r[$c] = $r[$a] | $b;
        }
        elsif ($op eq "setr")
        {
            $r[$c] = $r[$a];
        }
        elsif ($op eq "seti")
        {
            $r[$c] = $a;
        }
        elsif ($op eq "gtir")
        {
            $r[$c] = ($a > $r[$b]) ? 1 : 0;
        }
        elsif ($op eq "gtri")
        {
            $r[$c] = ($r[$a] > $b) ? 1 : 0;
        }
        elsif ($op eq "gtrr")
        {
            $r[$c] = ($r[$a] > $r[$b]) ? 1 : 0;
        }
        elsif ($op eq "eqir")
        {
            $r[$c] = ($a == $r[$b]) ? 1 : 0;
        }
        elsif ($op eq "eqri")
        {
            $r[$c] = ($r[$a] == $b) ? 1 : 0;
        }
        elsif ($op eq "eqrr")
        {
            $r[$c] = ($r[$a] == $r[$b]) ? 1 : 0;
        }


        $ip = $r[$ip_reg];

        $ip++;

        $steps++;
    }


    return @r;
}


# -------------------------------------------------
# Sum divisors
# -------------------------------------------------

sub divisors_sum
{
    my ($n) = @_;

    my $sum = 0;


    my $i = 1;


    while ($i * $i <= $n)
    {
        if ($n % $i == 0)
        {
            $sum += $i;


            if ($i * $i != $n)
            {
                $sum += int($n / $i);
            }
        }


        $i++;
    }


    return $sum;
}


# -------------------------------------------------
# Part 1
# -------------------------------------------------

sub part1
{
    my ($ip_reg, $prog) = @_;

    my @r = run($ip_reg, $prog);

    return $r[0];
}


# -------------------------------------------------
# Part 2
# -------------------------------------------------

sub part2
{
    my ($ip_reg, $prog) = @_;


    my @r = run(
        $ip_reg,
        $prog,
        1,
        100
    );


    my $n = $r[0];

    for my $v (@r)
    {
        $n = $v if $v > $n;
    }


    return divisors_sum($n);
}


# -------------------------------------------------
# Main
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";


open(my $fh, '<', $file)
    or die "Cannot open $file: $!";


my $text = do {
    local $/;
    <$fh>;
};


close($fh);


my ($ip_reg, $prog) = parse($text);


my $p1 = part1($ip_reg, $prog);
my $p2 = part2($ip_reg, $prog);


print "2018 day19: pl_ans_1: $p1\n";
print "2018 day19: pl_ans_2: $p2\n";

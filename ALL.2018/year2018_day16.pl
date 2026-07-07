#!/usr/bin/perl

use strict;
use warnings;

# -------------------------------------------------
# Operations
# -------------------------------------------------

sub addr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] + $r->[$b];
}

sub addi
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] + $b;
}

sub mulr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] * $r->[$b];
}

sub muli
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] * $b;
}

sub banr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] & $r->[$b];
}

sub bani
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] & $b;
}

sub borr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] | $r->[$b];
}

sub bori
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a] | $b;
}

sub setr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $r->[$a];
}

sub seti
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = $a;
}

sub gtir
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($a > $r->[$b]) ? 1 : 0;
}

sub gtri
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($r->[$a] > $b) ? 1 : 0;
}

sub gtrr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($r->[$a] > $r->[$b]) ? 1 : 0;
}

sub eqir
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($a == $r->[$b]) ? 1 : 0;
}

sub eqri
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($r->[$a] == $b) ? 1 : 0;
}

sub eqrr
{
    my ($r, $a, $b, $c) = @_;
    $r->[$c] = ($r->[$a] == $r->[$b]) ? 1 : 0;
}


my @OPS =
(
    \&addr, \&addi,
    \&mulr, \&muli,
    \&banr, \&bani,
    \&borr, \&bori,
    \&setr, \&seti,
    \&gtir, \&gtri, \&gtrr,
    \&eqir, \&eqri, \&eqrr,
);


# -------------------------------------------------
# Parse input
# -------------------------------------------------

sub parse_input
{
    my ($text) = @_;

    my @samples;
    my @program;


    my @parts = split(/\n\n\n\n/, $text);

    my $sample_part  = $parts[0];
    my $program_part = $parts[1];


    my @blocks = split(/\n\n/, $sample_part);


    for my $block (@blocks)
    {
        my @lines = split(/\n/, $block);

        my @before = ($lines[0] =~ /\d+/g);
        my @instr  = split(/\s+/, $lines[1]);
        my @after  = ($lines[2] =~ /\d+/g);


        push @samples,
        [
            \@before,
            \@instr,
            \@after
        ];
    }


    for my $line (split(/\n/, $program_part))
    {
        next if $line eq '';

        push @program,
        [
            split(/\s+/, $line)
        ];
    }


    return (\@samples, \@program);
}


# -------------------------------------------------
# Test operation
# -------------------------------------------------

sub matches
{
    my ($op, $before, $instr, $after) = @_;


    my @r = @$before;


    my ($opcode, $a, $b, $c) = @$instr;


    $op->(\@r, $a, $b, $c);


    for my $i (0 .. 3)
    {
        return 0 if $r[$i] != $after->[$i];
    }


    return 1;
}


# -------------------------------------------------
# Solve
# -------------------------------------------------

sub solve
{
    my ($text) = @_;


    my ($samples, $program) = parse_input($text);


    my $part1 = 0;


    my %possible;


    for my $sample (@$samples)
    {
        my ($before, $instr, $after) = @$sample;


        my $opcode = $instr->[0];


        my %valid;


        for my $op (@OPS)
        {
            if (matches($op, $before, $instr, $after))
            {
                $valid{"$op"} = $op;
            }
        }


        if (scalar(keys %valid) >= 3)
        {
            $part1++;
        }


        if (!exists $possible{$opcode})
        {
            $possible{$opcode} = {};
        }


        for my $op (keys %valid)
        {
            $possible{$opcode}{$op} = $valid{$op};
        }
    }


    # -------------------------------------------------
    # Deduce opcode mapping
    # -------------------------------------------------

    my %opcode_map;


    while (keys %possible)
    {
        my @determined;


        for my $opcode (keys %possible)
        {
            if (scalar(keys %{$possible{$opcode}}) == 1)
            {
                push @determined, $opcode;
            }
        }


        for my $opcode (@determined)
        {
            my ($key) = keys %{$possible{$opcode}};

            my $op = $possible{$opcode}{$key};


            $opcode_map{$opcode} = $op;


            delete $possible{$opcode};


            for my $other (keys %possible)
            {
                delete $possible{$other}{$key};
            }
        }
    }


    # -------------------------------------------------
    # Execute program
    # -------------------------------------------------

    my @regs = (0,0,0,0);


    for my $instr (@$program)
    {
        my ($opcode, $a, $b, $c) = @$instr;

        $opcode_map{$opcode}->(\@regs, $a, $b, $c);
    }


    return ($part1, $regs[0]);
}


# -------------------------------------------------
# Main
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";


open(my $fh, '<', $file) or die "Cannot open $file: $!";

my $text = do {
    local $/;
    <$fh>;
};

close($fh);


my ($p1, $p2) = solve($text);


print "2018 day16: pl_ans_1: $p1\n";
print "2018 day16: pl_ans_2: $p2\n";

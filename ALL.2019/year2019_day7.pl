#!/usr/bin/perl

use strict;
use warnings;

# -------------------------
# Intcode Computer (FIXED)
# -------------------------

package Intcode;

sub new {

    my ($class, $program) = @_;

    my @mem = @$program;

    my $self = {
        mem     => \@mem,
        ip      => 0,
        inputs  => [],
        halted  => 0,
    };

    bless $self, $class;

    return $self;
}


sub run {

    my ($self) = @_;

    my $mem = $self->{mem};

    while (1) {

        my $instruction = $mem->[ $self->{ip} ];

        my $op = $instruction % 100;

        my $m1 = int($instruction / 100) % 10;
        my $m2 = int($instruction / 1000) % 10;

        my $get = sub {

            my ($param, $mode) = @_;

            return $mode == 1
                ? $param
                : $mem->[$param];
        };


        if ($op == 99) {

            $self->{halted} = 1;

            return undef;
        }


        elsif ($op == 1) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            $mem->[
                $mem->[ $self->{ip}+3 ]
            ] = $a + $b;

            $self->{ip} += 4;
        }


        elsif ($op == 2) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            $mem->[
                $mem->[ $self->{ip}+3 ]
            ] = $a * $b;

            $self->{ip} += 4;
        }


        elsif ($op == 3) {

            return undef
                unless @{ $self->{inputs} };

            $mem->[
                $mem->[ $self->{ip}+1 ]
            ] =
                shift @{ $self->{inputs} };

            $self->{ip} += 2;
        }


        elsif ($op == 4) {

            my $val =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            $self->{ip} += 2;

            return $val;
        }


        elsif ($op == 5) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            if ($a != 0) {

                $self->{ip} = $b;
            }
            else {

                $self->{ip} += 3;
            }
        }


        elsif ($op == 6) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            if ($a == 0) {

                $self->{ip} = $b;
            }
            else {

                $self->{ip} += 3;
            }
        }


        elsif ($op == 7) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            $mem->[
                $mem->[ $self->{ip}+3 ]
            ] =
                ($a < $b) ? 1 : 0;

            $self->{ip} += 4;
        }


        elsif ($op == 8) {

            my $a =
                $get->(
                    $mem->[ $self->{ip}+1 ],
                    $m1
                );

            my $b =
                $get->(
                    $mem->[ $self->{ip}+2 ],
                    $m2
                );

            $mem->[
                $mem->[ $self->{ip}+3 ]
            ] =
                ($a == $b) ? 1 : 0;

            $self->{ip} += 4;
        }


        else {

            die "Bad opcode $op\n";
        }
    }
}

package main;

# -------------------------
# Generate permutations
# -------------------------

sub permutations {

    my ($items) = @_;

    return [[]] unless @$items;

    my @result;

    for my $i (0 .. $#$items) {

        my @rest = @$items;

        my $first = splice(@rest, $i, 1);

        for my $p (@{ permutations(\@rest) }) {

            push @result, [ $first, @$p ];
        }
    }

    return \@result;
}


# -------------------------
# Part 1 (no feedback loop)
# -------------------------

sub run_chain {

    my ($program, $phases) = @_;

    my $signal = 0;

    for my $p (@$phases) {

        my $vm = Intcode->new($program);

        push @{ $vm->{inputs} }, $p;
        push @{ $vm->{inputs} }, $signal;

        my $out = $vm->run();

        while (!defined $out) {

            $out = $vm->run();
        }

        $signal = $out;
    }

    return $signal;
}


# -------------------------
# Part 2 (feedback loop)
# -------------------------

sub run_feedback {

    my ($program, $phases) = @_;

    my @vms;

    for (@$phases) {

        push @vms, Intcode->new($program);
    }

    for my $i (0 .. 4) {

        push @{ $vms[$i]{inputs} }, $phases->[$i];
    }

    my $signal = 0;

    my $i = 0;

    while (!$vms[4]{halted}) {

        my $vm = $vms[$i % 5];

        push @{ $vm->{inputs} }, $signal;

        my $out = $vm->run();

        if (defined $out) {

            $signal = $out;
        }

        $i++;
    }

    return $signal;
}


# -------------------------
# Main
# -------------------------

sub main {

    my $infile = $ARGV[0];

    open my $fh, "<", $infile or die $!;

    chomp(my $line = <$fh>);

    close $fh;

    my @program =
        map { int($_) }
        split /,/, $line;


    my $p1 = 0;

    for my $perm (@{ permutations([0,1,2,3,4]) }) {

        my $ans =
            run_chain(
                \@program,
                $perm
            );

        $p1 = $ans
            if $ans > $p1;
    }


    my $p2 = 0;

    for my $perm (@{ permutations([5,6,7,8,9]) }) {

        my $ans =
            run_feedback(
                \@program,
                $perm
            );

        $p2 = $ans
            if $ans > $p2;
    }


    print "2019 day7: pl_ans_1: $p1\n";
    print "2019 day7: pl_ans_2: $p2\n";
}


main();

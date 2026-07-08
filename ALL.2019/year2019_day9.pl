#!/usr/bin/perl

use strict;
use warnings;

# -------------------------
# Intcode Computer
# -------------------------

package Intcode;

sub new {

    my ($class, $program) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }

    my $self = {
        mem     => \%mem,
        ip      => 0,
        rb      => 0,
        inputs  => [],
        halted  => 0,
    };

    bless $self, $class;

    return $self;
}


sub get {

    my ($self, $mode, $val) = @_;

    if ($mode == 0) {

        return $self->{mem}{$val} // 0;

    }
    elsif ($mode == 1) {

        return $val;

    }
    elsif ($mode == 2) {

        return $self->{mem}{ $self->{rb} + $val } // 0;

    }

    die "Bad mode $mode\n";
}


sub set {

    my ($self, $mode, $addr, $value) = @_;

    if ($mode == 2) {

        $self->{mem}{ $self->{rb} + $addr } = $value;

    }
    else {

        $self->{mem}{$addr} = $value;

    }
}


sub run {

    my ($self) = @_;

    while (1) {

        my $instr =
            $self->{mem}{ $self->{ip} } // 0;

        my $op = $instr % 100;

        my $m1 = int($instr / 100) % 10;
        my $m2 = int($instr / 1000) % 10;
        my $m3 = int($instr / 10000) % 10;


        if ($op == 99) {

            $self->{halted} = 1;

            return undef;
        }


        elsif ($op == 1) {

            my $a =
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
                );

            $self->set(
                $m3,
                $self->{mem}{$self->{ip}+3} // 0,
                $a + $b
            );

            $self->{ip} += 4;
        }


        elsif ($op == 2) {

            my $a =
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
                );

            $self->set(
                $m3,
                $self->{mem}{$self->{ip}+3} // 0,
                $a * $b
            );

            $self->{ip} += 4;
        }


        elsif ($op == 3) {

            return undef
                unless @{ $self->{inputs} };

            my $value =
                shift @{ $self->{inputs} };

            $self->set(
                $m1,
                $self->{mem}{$self->{ip}+1} // 0,
                $value
            );

            $self->{ip} += 2;
        }


        elsif ($op == 4) {

            my $val =
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            $self->{ip} += 2;

            return $val;
        }


        elsif ($op == 5) {

            my $a =
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
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
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
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
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
                );

            $self->set(
                $m3,
                $self->{mem}{$self->{ip}+3} // 0,
                ($a < $b) ? 1 : 0
            );

            $self->{ip} += 4;
        }


        elsif ($op == 8) {

            my $a =
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            my $b =
                $self->get(
                    $m2,
                    $self->{mem}{$self->{ip}+2} // 0
                );

            $self->set(
                $m3,
                $self->{mem}{$self->{ip}+3} // 0,
                ($a == $b) ? 1 : 0
            );

            $self->{ip} += 4;
        }


        elsif ($op == 9) {

            $self->{rb} +=
                $self->get(
                    $m1,
                    $self->{mem}{$self->{ip}+1} // 0
                );

            $self->{ip} += 2;
        }


        else {

            die "Bad opcode $op\n";
        }
    }
}

package main;

# -------------------------
# Main
# -------------------------

sub main {

    my $path = $ARGV[0];

    open my $fh, '<', $path or die $!;

    chomp(my $line = <$fh>);

    close $fh;


    my @program =
        map { int($_) }
        split /,/, $line;


    # -------------------------
    # Part 1
    # -------------------------

    my $vm1 = Intcode->new(\@program);

    $vm1->{inputs} = [1];

    my $p1;


    while (!$vm1->{halted}) {

        my $out = $vm1->run();

        if (defined $out) {

            $p1 = $out;
        }
    }


    # -------------------------
    # Part 2
    # -------------------------

    my $vm2 = Intcode->new(\@program);

    $vm2->{inputs} = [2];

    my $p2;


    while (!$vm2->{halted}) {

        my $out = $vm2->run();

        if (defined $out) {

            $p2 = $out;
        }
    }


    print "2019 day9: pl_ans_1: $p1\n";
    print "2019 day9: pl_ans_2: $p2\n";
}


main();

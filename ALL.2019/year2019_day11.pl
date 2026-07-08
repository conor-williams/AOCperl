#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';


# ============================================================
# Intcode VM
# ============================================================

package Intcode;

use strict;
use warnings;


sub new {
    my ($class, $program) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }

    return bless {
        mem => \%mem,
        ip => 0,
        rb => 0,
        inputs => [],
        halted => 0
    }, $class;
}


sub get {

    my ($self,$mode,$val) = @_;

    my $mem = $self->{mem};

    if ($mode == 0) {
        return $mem->{$val} // 0;
    }
    elsif ($mode == 1) {
        return $val;
    }
    else {
        return $mem->{$self->{rb} + $val} // 0;
    }
}


sub set {

    my ($self,$mode,$addr,$value) = @_;

    if ($mode == 2) {
        $self->{mem}->{$self->{rb} + $addr} = $value;
    }
    else {
        $self->{mem}->{$addr} = $value;
    }
}


sub run {

    my ($self) = @_;

    while (1) {

        my $instr = $self->{mem}->{$self->{ip}} // 0;

        my $op = $instr % 100;

        my $m1 = int($instr / 100) % 10;
        my $m2 = int($instr / 1000) % 10;
        my $m3 = int($instr / 10000) % 10;


        if ($op == 99) {

            $self->{halted} = 1;
            return undef;

        }


        elsif ($op == 1) {

            my $a = $self->get($m1,$self->{mem}->{$self->{ip}+1});
            my $b = $self->get($m2,$self->{mem}->{$self->{ip}+2});

            $self->set(
                $m3,
                $self->{mem}->{$self->{ip}+3},
                $a+$b
            );

            $self->{ip} += 4;
        }


        elsif ($op == 2) {

            my $a = $self->get($m1,$self->{mem}->{$self->{ip}+1});
            my $b = $self->get($m2,$self->{mem}->{$self->{ip}+2});

            $self->set(
                $m3,
                $self->{mem}->{$self->{ip}+3},
                $a*$b
            );

            $self->{ip} += 4;
        }


        elsif ($op == 3) {

            if (!@{$self->{inputs}}) {
                return undef;
            }

            $self->set(
                $m1,
                $self->{mem}->{$self->{ip}+1},
                shift @{$self->{inputs}}
            );

            $self->{ip} += 2;
        }


        elsif ($op == 4) {

            my $out =
                $self->get(
                    $m1,
                    $self->{mem}->{$self->{ip}+1}
                );

            $self->{ip} += 2;

            return $out;
        }


        elsif ($op == 5) {

            if ($self->get($m1,$self->{mem}->{$self->{ip}+1}) != 0) {
                $self->{ip} =
                    $self->get($m2,$self->{mem}->{$self->{ip}+2});
            }
            else {
                $self->{ip} += 3;
            }
        }


        elsif ($op == 6) {

            if ($self->get($m1,$self->{mem}->{$self->{ip}+1}) == 0) {
                $self->{ip} =
                    $self->get($m2,$self->{mem}->{$self->{ip}+2});
            }
            else {
                $self->{ip} += 3;
            }
        }


        elsif ($op == 7) {

            $self->set(
                $m3,
                $self->{mem}->{$self->{ip}+3},
                $self->get($m1,$self->{mem}->{$self->{ip}+1})
                <
                $self->get($m2,$self->{mem}->{$self->{ip}+2})
                ? 1 : 0
            );

            $self->{ip} += 4;
        }


        elsif ($op == 8) {

            $self->set(
                $m3,
                $self->{mem}->{$self->{ip}+3},
                $self->get($m1,$self->{mem}->{$self->{ip}+1})
                ==
                $self->get($m2,$self->{mem}->{$self->{ip}+2})
                ? 1 : 0
            );

            $self->{ip} += 4;
        }


        elsif ($op == 9) {

            $self->{rb} +=
                $self->get(
                    $m1,
                    $self->{mem}->{$self->{ip}+1}
                );

            $self->{ip} += 2;
        }


        else {
            die "Bad opcode $op";
        }
    }
}


package main;


# ============================================================
# Robot
# ============================================================


sub turn {

    my ($dir,$t) = @_;

    return $t == 0
        ? ($dir - 1) % 4
        : ($dir + 1) % 4;
}


sub move {

    my ($x,$y,$d)=@_;

    return ($x,$y-1) if $d == 0;
    return ($x+1,$y) if $d == 1;
    return ($x,$y+1) if $d == 2;

    return ($x-1,$y);
}



sub run_robot {

    my ($program,$start_color)=@_;


    my $vm = Intcode->new($program);


    my %grid;

    my ($x,$y)=(0,0);

    my $direction=0;


    $grid{"$x,$y"}=$start_color;


    my %painted;


    while (!$vm->{halted}) {


        push @{$vm->{inputs}},
            $grid{"$x,$y"} // 0;


        my $color=$vm->run();

        last if $vm->{halted};


        my $turn=$vm->run();

        last if $vm->{halted};


        $grid{"$x,$y"}=$color;

        $painted{"$x,$y"}=1;


        $direction=turn($direction,$turn);


        ($x,$y)=move($x,$y,$direction);
    }


    return (\%painted,\%grid);
}



# ============================================================
# MAIN
# ============================================================


open(my $fh,"<",$ARGV[0])
    or die;

my $line=<$fh>;

close($fh);


my @program=split /,/, $line;


# Part 1

my ($painted,$grid)=run_robot(\@program,0);

my $p1=scalar keys %$painted;



# Part 2

(undef,$grid)=run_robot(\@program,1);


my @pts =
    grep {
        ($grid->{$_} // 0) == 1
    } keys %$grid;


my (@xs,@ys);

for my $p (@pts) {

    my ($x,$y)=split /,/,$p;

    push @xs,$x;
    push @ys,$y;
}


my $minx=(sort {$a<=>$b} @xs)[0];
my $maxx=(sort {$b<=>$a} @xs)[0];

my $miny=(sort {$a<=>$b} @ys)[0];
my $maxy=(sort {$b<=>$a} @ys)[0];


say "2019 day11: pl_ans_1: $p1";

say "2019 day11: pl_ans_2:";


for my $y ($miny .. $maxy) {

    my $row="";

    for my $x ($minx .. $maxx) {

        $row .=
            (($grid->{"$x,$y"} // 0) == 1)
            ? "#"
            : " ";
    }

    say $row;
}

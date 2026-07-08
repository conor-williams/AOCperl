#!/usr/bin/perl
use strict;
use warnings;


# ============================================================
# Intcode
# ============================================================

package IntCode;

use strict;
use warnings;


sub new {
    my ($class, $program, $inputs, $input_callback) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }

    return bless {
        mem => \%mem,
        ip => 0,
        rb => 0,
        inputs => $inputs // [],
        callback => $input_callback,
        halted => 0,
    }, $class;
}


sub get_mem {
    my ($self,$a)=@_;
    return $self->{mem}{$a} // 0;
}


sub set_mem {
    my ($self,$a,$v)=@_;
    $self->{mem}{$a}=$v;
}


sub get_param {
    my ($self,$mode,$val)=@_;

    if ($mode == 0) {
        return $self->get_mem($val);
    }
    elsif ($mode == 1) {
        return $val;
    }
    elsif ($mode == 2) {
        return $self->get_mem($self->{rb}+$val);
    }

    die "bad mode";
}


sub set_param {
    my ($self,$mode,$addr,$value)=@_;

    if ($mode == 2) {
        $self->set_mem(
            $self->{rb}+$addr,
            $value
        );
    }
    else {
        $self->set_mem($addr,$value);
    }
}



sub run {

    my ($self)=@_;


    while (1) {


        my $instr =
            $self->get_mem($self->{ip});


        my $op =
            $instr % 100;


        my $m1 =
            int($instr/100)%10;

        my $m2 =
            int($instr/1000)%10;

        my $m3 =
            int($instr/10000)%10;



        if ($op == 99) {

            $self->{halted}=1;

            return undef;
        }



        elsif ($op == 1) {

            my $a=$self->get_param(
                $m1,
                $self->get_mem($self->{ip}+1)
            );

            my $b=$self->get_param(
                $m2,
                $self->get_mem($self->{ip}+2)
            );


            $self->set_param(
                $m3,
                $self->get_mem($self->{ip}+3),
                $a+$b
            );


            $self->{ip}+=4;
        }



        elsif ($op == 2) {

            my $a=$self->get_param(
                $m1,
                $self->get_mem($self->{ip}+1)
            );

            my $b=$self->get_param(
                $m2,
                $self->get_mem($self->{ip}+2)
            );


            $self->set_param(
                $m3,
                $self->get_mem($self->{ip}+3),
                $a*$b
            );


            $self->{ip}+=4;
        }



        elsif ($op == 3) {


            my $input;


            if (@{$self->{inputs}}) {
                $input =
                    shift @{$self->{inputs}};
            }

            elsif ($self->{callback}) {
                $input =
                    $self->{callback}->();
            }

            else {
                $input=0;
            }


            $self->set_param(
                $m1,
                $self->get_mem($self->{ip}+1),
                $input
            );


            $self->{ip}+=2;
        }



        elsif ($op == 4) {

            my $out =
                $self->get_param(
                    $m1,
                    $self->get_mem($self->{ip}+1)
                );


            $self->{ip}+=2;

            return $out;
        }



        elsif ($op == 5) {

            if (
                $self->get_param($m1,$self->get_mem($self->{ip}+1))
                !=0
            ) {
                $self->{ip}=
                    $self->get_param($m2,$self->get_mem($self->{ip}+2));
            }
            else {
                $self->{ip}+=3;
            }
        }



        elsif ($op == 6) {

            if (
                $self->get_param($m1,$self->get_mem($self->{ip}+1))
                ==0
            ) {
                $self->{ip}=
                    $self->get_param($m2,$self->get_mem($self->{ip}+2));
            }
            else {
                $self->{ip}+=3;
            }
        }



        elsif ($op == 7) {

            my $v =
                $self->get_param($m1,$self->get_mem($self->{ip}+1))
                <
                $self->get_param($m2,$self->get_mem($self->{ip}+2));


            $self->set_param(
                $m3,
                $self->get_mem($self->{ip}+3),
                $v ? 1:0
            );


            $self->{ip}+=4;
        }



        elsif ($op == 8) {

            my $v =
                $self->get_param($m1,$self->get_mem($self->{ip}+1))
                ==
                $self->get_param($m2,$self->get_mem($self->{ip}+2));


            $self->set_param(
                $m3,
                $self->get_mem($self->{ip}+3),
                $v ? 1:0
            );


            $self->{ip}+=4;
        }



        elsif ($op == 9) {

            $self->{rb} +=
                $self->get_param(
                    $m1,
                    $self->get_mem($self->{ip}+1)
                );


            $self->{ip}+=2;
        }


        else {
            die "bad opcode $op";
        }
    }
}



# ============================================================
# Main
# ============================================================

package main;

use strict;
use warnings;



sub part1 {

    my ($code)=@_;


    my $program =
        IntCode->new($code);


    my $blocks=0;


    while (!$program->{halted}) {


        $program->run();

        $program->run();

        my $blocktype =
            $program->run();


        $blocks++ if defined($blocktype) && $blocktype == 2;
    }


    return $blocks;
}



sub part2 {

    my ($code)=@_;


    my ($ball_x,$paddle_x);


    my $program =
        IntCode->new(
            $code,
            [],
            sub {
                return ($ball_x > $paddle_x)
                    - ($ball_x < $paddle_x);
            }
        );


    # program[0] = 2
    $program->set_mem(0,2);


    my $last_points=0;


    while (!$program->{halted}) {


        my $x=$program->run();

        my $y=$program->run();

        my $blocktype=$program->run();


        last if $program->{halted};



        if ($blocktype == 3) {
            $paddle_x=$x;
        }


        elsif ($blocktype == 4) {
            $ball_x=$x;
        }


        if ($x == -1 && $y == 0) {
            $last_points=$blocktype;
        }
    }


    return $last_points;
}



my $file=shift @ARGV;


open my $fh,"<",$file or die $!;

my $line=<$fh>;

close $fh;


my @code =
    split /,/,$line;


print "2019 day13: pl_ans_1: ",
      part1(\@code),
      "\n";


print "2019 day13: pl_ans_2: ",
      part2(\@code),
      "\n";

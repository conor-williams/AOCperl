#!/usr/bin/perl
use strict;
use warnings;

my $file = shift @ARGV;

open(my $fh, "<", $file) or die $!;
my $text = <$fh>;
close($fh);

chomp $text;

my @program = split(/,/, $text);


# ============================================================
# INT CODE VM
# ============================================================

package VM;

sub new {
    my ($class, $program, $addr) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }

    return bless {
        mem  => \%mem,
        ip   => 0,
        base => 0,
        inp  => [$addr],
        inpos => 0,
        out  => []
    }, $class;
}


sub memget {
    my ($self,$a)=@_;

    return exists $self->{mem}{$a}
        ? $self->{mem}{$a}
        : 0;
}


sub memset {
    my ($self,$a,$v)=@_;

    $self->{mem}{$a}=$v;
}


sub get {
    my ($self,$a,$mode)=@_;

    if ($mode == 0) {
        return $self->memget($self->memget($a));
    }
    elsif ($mode == 1) {
        return $self->memget($a);
    }
    elsif ($mode == 2) {
        return $self->memget($self->{base}+$self->memget($a));
    }
}


sub addr {
    my ($self,$a,$mode)=@_;

    if ($mode == 2) {
        return $self->{base}+$self->memget($a);
    }

    return $self->memget($a);
}


sub push_input {
    my ($self,$v)=@_;

    push @{$self->{inp}},$v;
}


sub run {

    my ($self)=@_;

    while(1) {

        my $op = $self->memget($self->{ip});

        my $m1 = int($op/100)%10;
        my $m2 = int($op/1000)%10;
        my $m3 = int($op/10000)%10;

        $op %= 100;


        if ($op == 99) {
            return "halt";
        }


        elsif ($op == 1 || $op == 2 ||
               $op == 7 || $op == 8) {


            my $a=$self->get($self->{ip}+1,$m1);
            my $b=$self->get($self->{ip}+2,$m2);
            my $c=$self->addr($self->{ip}+3,$m3);

            if ($op==1) {
                $self->memset($c,$a+$b);
            }
            elsif ($op==2) {
                $self->memset($c,$a*$b);
            }
            elsif ($op==7) {
                $self->memset($c,$a<$b?1:0);
            }
            else {
                $self->memset($c,$a==$b?1:0);
            }

            $self->{ip}+=4;
        }


        elsif ($op==3) {

            my $c=$self->addr($self->{ip}+1,$m1);

            if ($self->{inpos} < @{$self->{inp}}) {

                my $v =
                    $self->{inp}[$self->{inpos}++];

                $self->memset($c,$v);
            }
            else {

                $self->memset($c,-1);
                $self->{ip}+=2;

                return "blocked";
            }

            $self->{ip}+=2;
        }


        elsif ($op==4) {

            my $v=$self->get($self->{ip}+1,$m1);

            push @{$self->{out}},$v;

            $self->{ip}+=2;

            if (@{$self->{out}} >= 3) {
                return "output";
            }
        }


        elsif ($op==5) {

            my $a=$self->get($self->{ip}+1,$m1);
            my $b=$self->get($self->{ip}+2,$m2);

            if ($a!=0) {
                $self->{ip}=$b;
            }
            else {
                $self->{ip}+=3;
            }
        }


        elsif ($op==6) {

            my $a=$self->get($self->{ip}+1,$m1);
            my $b=$self->get($self->{ip}+2,$m2);

            if ($a==0) {
                $self->{ip}=$b;
            }
            else {
                $self->{ip}+=3;
            }
        }


        elsif ($op==9) {

            $self->{base} +=
                $self->get($self->{ip}+1,$m1);

            $self->{ip}+=2;
        }
    }
}



package main;


# ============================================================
# NETWORK
# ============================================================


my @vm;

for my $i (0..49) {
    $vm[$i]=VM->new(\@program,$i);
}


my @queue;

for my $i (0..49) {
    $queue[$i]=[];
}


my $nat_x;
my $nat_y;

my $last_nat_y;

my $part1;


while(1) {


    my $idle=1;


    for my $i (0..49) {


        if (@{$queue[$i]}) {

            my $x=shift @{$queue[$i]};
            my $y=shift @{$queue[$i]};

            $vm[$i]->push_input($x);
            $vm[$i]->push_input($y);
        }


        my $status=$vm[$i]->run();


        if (@{$vm[$i]->{out}} >= 3) {

            $idle=0;


            while (@{$vm[$i]->{out}} >=3) {

                my $d=shift @{$vm[$i]->{out}};
                my $x=shift @{$vm[$i]->{out}};
                my $y=shift @{$vm[$i]->{out}};


                if ($d==255) {

                    $nat_x=$x;
                    $nat_y=$y;

                    $part1=$y
                        unless defined $part1;
                }
                else {

                    push @{$queue[$d]},$x;
                    push @{$queue[$d]},$y;
                }
            }
        }
    }


    if ($idle && defined $nat_y) {


        if (defined $last_nat_y &&
            $last_nat_y==$nat_y) {

            print "2019 day23: pl_ans_1: $part1\n";
            print "2019 day23: pl_ans_2: $nat_y\n";
            last;
        }


        $last_nat_y=$nat_y;

        push @{$queue[0]},$nat_x;
        push @{$queue[0]},$nat_y;
    }
}

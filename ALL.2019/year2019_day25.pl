#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

use Term::ReadLine;


# ============================================================
# VM
# ============================================================

package VM;

use strict;
use warnings;
use List::Util qw();

sub new {
    my ($class, $program) = @_;

    my %mem;

    for my $i (0 .. $#$program) {
        $mem{$i} = $program->[$i];
    }

    return bless {
        mem => \%mem,
        ip  => 0,
        rb  => 0,
        inp => [],
    }, $class;
}


sub send {
    my ($self, $s) = @_;

    push @{$self->{inp}}, map { ord($_) } split //, $s;
}


sub run {

    my ($self) = @_;

    my $mem = $self->{mem};
    my $ip  = $self->{ip};
    my $rb  = $self->{rb};
    my $inp = $self->{inp};

    my $out = "";


    sub get_param {
        my ($mem,$rb,$i,$mode) = @_;

        if ($mode == 0) {
            return $mem->{$mem->{$i}} // 0;
        }
        elsif ($mode == 1) {
            return $mem->{$i} // 0;
        }
        else {
            return $mem->{$rb + ($mem->{$i} // 0)} // 0;
        }
    }


    sub get_addr {
        my ($mem,$rb,$i,$mode) = @_;

        if ($mode == 0) {
            return $mem->{$i};
        }
        else {
            return $rb + $mem->{$i};
        }
    }


    while (1) {

        my $op = $mem->{$ip} // 0;

        my $m1 = int($op / 100) % 10;
        my $m2 = int($op / 1000) % 10;
        my $m3 = int($op / 10000) % 10;

        $op %= 100;


        if ($op == 1) {

            $mem->{get_addr($mem,$rb,$ip+3,$m3)} =
                get_param($mem,$rb,$ip+1,$m1)
              + get_param($mem,$rb,$ip+2,$m2);

            $ip += 4;

        }

        elsif ($op == 2) {

            $mem->{get_addr($mem,$rb,$ip+3,$m3)} =
                get_param($mem,$rb,$ip+1,$m1)
              * get_param($mem,$rb,$ip+2,$m2);

            $ip += 4;

        }

        elsif ($op == 3) {

            if (!@$inp) {

                $self->{ip} = $ip;
                $self->{rb} = $rb;

                return ($out,0);
            }


            $mem->{get_addr($mem,$rb,$ip+1,$m1)}
                = shift @$inp;

            $ip += 2;

        }

        elsif ($op == 4) {

            $out .= chr(
                get_param($mem,$rb,$ip+1,$m1)
            );

            $ip += 2;

        }

        elsif ($op == 5) {

            if (get_param($mem,$rb,$ip+1,$m1) != 0) {
                $ip = get_param($mem,$rb,$ip+2,$m2);
            }
            else {
                $ip += 3;
            }

        }

        elsif ($op == 6) {

            if (get_param($mem,$rb,$ip+1,$m1) == 0) {
                $ip = get_param($mem,$rb,$ip+2,$m2);
            }
            else {
                $ip += 3;
            }

        }

        elsif ($op == 7) {

            $mem->{get_addr($mem,$rb,$ip+3,$m3)} =
                get_param($mem,$rb,$ip+1,$m1)
                <
                get_param($mem,$rb,$ip+2,$m2)
                ? 1 : 0;

            $ip += 4;

        }

        elsif ($op == 8) {

            $mem->{get_addr($mem,$rb,$ip+3,$m3)} =
                get_param($mem,$rb,$ip+1,$m1)
                ==
                get_param($mem,$rb,$ip+2,$m2)
                ? 1 : 0;

            $ip += 4;

        }

        elsif ($op == 9) {

            $rb += get_param($mem,$rb,$ip+1,$m1);

            $ip += 2;

        }

        elsif ($op == 99) {

            return ($out,1);

        }
    }
}


1;


# ============================================================
# MAIN
# ============================================================

package main;

my $file = $ARGV[0];

open(my $fh,"<",$file)
    or die "Cannot open $file\n";

my $text = <$fh>;

close($fh);


my @program = split /,/, $text;

my $vm = VM->new(\@program);


print "=== START ===\n";


sub step {

    my ($cmd) = @_;

    $vm->send($cmd . "\n");

    return $vm->run();
}


my ($buffer,$halted) = $vm->run();

print $buffer;


my $term = Term::ReadLine->new('AoC 2019 Day25');


while (1) {

    my $cmd = $term->readline("> ");

    last unless defined $cmd;


    my ($out,$done) = step($cmd);

    print $out;


    if ($out =~ /Security Checkpoint/) {

        print "\nFOUND CHECKPOINT\n";

        last;
    }


    if ($done) {

        print "HALTED\n";

        last;
    }
}

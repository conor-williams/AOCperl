#!/usr/bin/perl
use strict;
use warnings;


sub parse {

    my ($line) = @_;

    chomp($line);

    return split(/,/, $line);
}



sub dance {

    my ($programs_ref, $moves_ref) = @_;

    my @programs = @$programs_ref;


    foreach my $m (@$moves_ref) {


        if (substr($m,0,1) eq "s") {

            my $x = int(substr($m,1));

            my @tail = splice(@programs, -$x);

            @programs = (@tail, @programs);


        } elsif (substr($m,0,1) eq "x") {


            my ($a,$b) = split(/\//, substr($m,1));

            my $tmp = $programs[$a];

            $programs[$a] = $programs[$b];
            $programs[$b] = $tmp;


        } elsif (substr($m,0,1) eq "p") {


            my ($a,$b) = split(/\//, substr($m,1));


            my $ia;
            my $ib;


            for (my $i=0; $i<scalar(@programs); $i++) {

                if ($programs[$i] eq $a) {
                    $ia = $i;
                }

                if ($programs[$i] eq $b) {
                    $ib = $i;
                }
            }


            my $tmp = $programs[$ia];

            $programs[$ia] = $programs[$ib];
            $programs[$ib] = $tmp;
        }
    }


    return join("", @programs);
}



sub solve {

    my ($moves_ref) = @_;


    my @start = split(//,"abcdefghijklmnop");


    # Part 1

    my $p1 = dance(\@start,$moves_ref);



    # Part 2

    my %seen;
    my @order;


    my @programs = @start;


    for (my $i=0; $i<1000000000; $i++) {


        my $state = join("",@programs);


        if (exists $seen{$state}) {


            my $cycle_start = $seen{$state};

            my $cycle_length = $i - $cycle_start;


            my $final_index =
                (1000000000 - $cycle_start) % $cycle_length;


            return (
                $p1,
                $order[$cycle_start + $final_index]
            );
        }


        $seen{$state} = $i;

        push @order,$state;


        my @next = split(//,dance(\@programs,$moves_ref));

        @programs = @next;
    }


    return ($p1,join("",@programs));
}



open(my $fh,"<",$ARGV[0]) or die "Cannot open file\n";

my $line = <$fh>;

close($fh);


my @moves = parse($line);


my ($p1,$p2)=solve(\@moves);


print "2017 day16: pl_ans_1: $p1\n";
print "2017 day16: pl_ans_2: $p2\n";

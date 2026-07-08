#!/usr/bin/perl
use strict;
use warnings;

my @inp;

open my $fh, "<", $ARGV[0] or die $!;
while (<$fh>) {
    chomp;
    push @inp, $_ if $_ ne "";
}
close $fh;


# ----------------------------
# Parse reactions
# ----------------------------

my %convs;

foreach my $line (@inp) {

    my ($left, $right) = split / => /, $line;

    my ($oq, $out) = split / /, $right;

    my %needs;

    foreach my $x (split /, /, $left) {

        my ($q, $n) = split / /, $x;

        $needs{$n} = int($q);
    }

    $convs{$out} = [
        int($oq),
        \%needs
    ];
}



# ----------------------------
# all_needs()
# ----------------------------

sub all_needs {

    my ($reqs_ref) = @_;

    my %nest = %{$reqs_ref};


    while (1) {

        my %n_nest = %nest;


        foreach my $l (keys %nest) {

            next if $l eq "ORE";

            foreach my $n (keys %{$convs{$l}[1]}) {
                $n_nest{$n} = 1;
            }
        }


        my $same = 1;

        foreach my $k (keys %nest) {
            if (!exists $n_nest{$k}) {
                $same = 0;
            }
        }

        foreach my $k (keys %n_nest) {
            if (!exists $nest{$k}) {
                $same = 0;
            }
        }


        last if $same;

        %nest = %n_nest;
    }


    return \%nest;
}



# ----------------------------
# make_x()
# ----------------------------

sub make_x {

    my ($x) = @_;


    my %reqs;


    foreach my $k (keys %{$convs{"FUEL"}[1]}) {

        $reqs{$k} =
            $convs{"FUEL"}[1]{$k} * $x;
    }



    while (scalar(keys %reqs) != 1 ||
           !exists $reqs{"ORE"}) {


        my ($k) = grep { $_ ne "ORE" } keys %reqs;


        my $r = delete $reqs{$k};


        my ($q, $needs) = @{$convs{$k}};


        my $needed = all_needs(\%reqs);


        if (exists $needed->{$k}) {

            $reqs{$k} = $r;

            next;
        }



        my $times = int(($r + $q - 1) / $q);



        foreach my $need (keys %{$needs}) {

            my $quan =
                $times * $needs->{$need};


            if (exists $reqs{$need}) {

                $reqs{$need} += $quan;

            }
            else {

                $reqs{$need} = $quan;
            }
        }
    }


    return \%reqs;
}



# ----------------------------
# Part 1
# ----------------------------

my $reqs = make_x(1);

my $p1 = $reqs->{"ORE"};

print "2019 day14: pl_ans_1: $p1\n";



# ----------------------------
# Part 2
# ----------------------------

my $TRL = 1000000000000;


sub search {

    my ($n) = @_;

    my $marg = 1;

    my $up = 1;



    while ($n * $marg >= 0.1) {


        while (1) {


            my $reqs = make_x($n);



            if ($up) {

                if ($reqs->{"ORE"} > $TRL) {
                    last;
                }

            }
            else {

                if ($reqs->{"ORE"} <= $TRL) {
                    last;
                }
            }



            if ($up) {

                $n = int($n * (1 + $marg));

            }
            else {

                $n = int($n * (1 - $marg));
            }
        }



        $up = !$up;

        $marg /= 10;
    }


    return $n;
}



my $p2 = search($TRL);


print "2019 day14: pl_ans_2: $p2\n";

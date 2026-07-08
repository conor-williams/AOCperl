#!/usr/bin/perl
use strict;
use warnings;

sub aoc_hash {
    my ($s) = @_;

    my $x = 0;

    foreach my $c (split(//, $s)) {
        $x = (($x + ord($c)) * 17) % 256;
    }

    return $x;
}


my $file = $ARGV[0];

open(my $fh, "<", $file) or die "Cannot open $file: $!";

local $/;
my $input_data = <$fh>;

close($fh);


# Python .strip() equivalent
$input_data =~ s/^\s+|\s+$//g;


my @steps = split(/,/, $input_data);


# -----------------
# Part 1
# -----------------

my $sum_hashes = 0;

foreach my $s (@steps) {
    $sum_hashes += aoc_hash($s);
}

print "2023 day15: pl_ans_1: $sum_hashes\n";

# -----------------
# Part 2
# -----------------

my @boxes;
my @order;

for (0 .. 255) {
    $boxes[$_] = {};
    $order[$_] = [];
}


foreach my $s (@steps) {

    if ($s =~ /^(.+)-$/) {

        my $lens_id = $1;
        my $box_id = aoc_hash($lens_id);

        delete $boxes[$box_id]{$lens_id};

        # remove from order list
        @{$order[$box_id]} =
            grep { $_ ne $lens_id } @{$order[$box_id]};

    }
    elsif ($s =~ /^(.+)=(\d+)$/) {

        my ($lens_id, $focal) = ($1, $2);

        my $box_id = aoc_hash($lens_id);

        if (!exists $boxes[$box_id]{$lens_id}) {
            push @{$order[$box_id]}, $lens_id;
        }

        $boxes[$box_id]{$lens_id} = int($focal);
    }
}


my $fp = 0;

for my $box_id (0 .. 255) {

    my $slot = 1;

    foreach my $lens (@{$order[$box_id]}) {

        $fp += ($box_id + 1)
             * $slot
             * $boxes[$box_id]{$lens};

        $slot++;
    }
}


print "2023 day15: pl_ans_2: $fp\n";

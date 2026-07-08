#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;

chomp(my $timestamp = <$fh>);
chomp(my $line = <$fh>);

close($fh);

my @parts = split /,/, $line;

my @busses;

for(my $i=0;$i<@parts;$i++){

    next if $parts[$i] eq "x";

    push @busses, [$i, int($parts[$i])];
}

# ---------------- Part 1 ----------------

my $min_wait = 1 << 60;
my $part1;

# ---------------- Part 2 ----------------

my $d = 1;
my $t = 0;

foreach my $b (@busses){

    my ($offset,$bus)=@$b;

    # Part 1

    my $loops = int(($timestamp + $bus - 1)/$bus);

    my $wait = $loops*$bus - $timestamp;

    if($wait < $min_wait){
        $min_wait = $wait;
        $part1 = $wait*$bus;
    }

    # Part 2

    while(1){

        $t += $d;

        if( (($t+$offset) % $bus) == 0 ){

            $d *= $bus;
            last;
        }
    }
}

print "2020 day13: pl_ans_1: $part1\n";
print "2020 day13: pl_ans_2: $t\n";

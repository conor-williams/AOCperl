#!/usr/bin/perl
use strict;
use warnings;

sub find_marker {

    my ($s,$size) = @_;

    for (my $i=0; $i <= length($s)-$size; $i++) {

        my %seen;

        my $ok = 1;

        for my $c (split //, substr($s,$i,$size)) {

            if ($seen{$c}) {
                $ok = 0;
                last;
            }

            $seen{$c} = 1;
        }

        return $i + $size if $ok;
    }

    return -1;
}


my $file = shift @ARGV or die "usage: perl year2022_day6.pl input.txt\n";

open(my $fh,"<",$file) or die "$!\n";

my $s = "";

while (<$fh>) {
    chomp;
    $s .= $_;
}

close($fh);


my $p1 = find_marker($s,4);
my $p2 = find_marker($s,14);

print "2022 day6: pl_ans_1: $p1\n";
print "2022 day6: pl_ans_2: $p2\n";

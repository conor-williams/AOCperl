#!/usr/bin/env perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

my $secret = <>;
chomp $secret;

sub find_hash {
    my ($prefix) = @_;

    my $i = 1;

    while (1) {
        my $hash = md5_hex($secret . $i);

        if (index($hash, $prefix) == 0) {
            return $i;
        }

        $i++;
    }
}

my $p1 = find_hash("00000");
my $p2 = find_hash("000000");

print "2015 day4: pl_ans_1: $p1\n";
print "2015 day4: pl_ans_2: $p2\n";

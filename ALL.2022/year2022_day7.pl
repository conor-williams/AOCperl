#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

open(my $fh, "<", $file) or die $!;

my @cwd;
my %files;
my %dirs;

while (<$fh>) {
    chomp;
    next if $_ eq "";

    my @parts = split;

    if ($parts[0] eq '$') {
        if ($parts[1] eq 'cd') {
            if ($parts[2] eq '/') {
                @cwd = ();
            }
            elsif ($parts[2] eq '..') {
                pop @cwd;
            }
            else {
                push @cwd, $parts[2];
                $dirs{join('/', @cwd)} = 1;
            }
        }
    }
    else {
        if ($parts[0] =~ /^\d+$/) {
            my $size = $parts[0];

            for my $i (0 .. scalar(@cwd)) {
                my $path = join('/', @cwd[0 .. $i-1]);
                $files{$path} += $size;
            }
        }
    }
}

# Part 1
my $p1 = 0;
for my $size (values %files) {
    $p1 += $size if $size <= 100000;
}

# Part 2
my $total  = 70000000;
my $needed = 30000000;
my $used   = $files{""};
my $free   = $total - $used;
my $need_to_free = $needed - $free;

my $p2 = 10**18;
for my $size (values %files) {
    if ($size >= $need_to_free && $size < $p2) {
        $p2 = $size;
    }
}

print "2022 day7: pl_ans_1: $p1\n";
print "2022 day7: pl_ans_2: $p2\n";

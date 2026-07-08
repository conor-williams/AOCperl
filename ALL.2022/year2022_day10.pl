#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

open(my $fh, "<", $file) or die $!;

my @lines;
while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @lines, $_;
}
close($fh);

my $x = 1;
my $cycle = 0;
my $p1 = 0;
my @crt;

sub tick {
    my ($xr, $cycler, $p1r, $crtr) = @_;

    my $pos = $$cycler % 40;
    push @$crtr, (abs($pos - $$xr) <= 1 ? "#" : ".");

    $$cycler++;

    if ((($$cycler - 20) % 40) == 0) {
        $$p1r += $$cycler * $$xr;
    }
}

for my $line (@lines) {

    if ($line eq "noop") {
        tick(\$x,\$cycle,\$p1,\@crt);
    }
    else {
        my (undef,$v)=split / /,$line;

        tick(\$x,\$cycle,\$p1,\@crt);
        tick(\$x,\$cycle,\$p1,\@crt);

        $x += $v;
    }
}

print "2022 day10: pl_ans_1: $p1\n";
print "2022 day10: pl_ans_2:\n";

for(my $i=0;$i<@crt;$i+=40){
    print join("",@crt[$i..$i+39]),"\n";
}

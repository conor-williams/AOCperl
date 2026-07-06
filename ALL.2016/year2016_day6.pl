use strict;
use warnings;

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my @lines = grep { $_ ne "" } map { chomp; $_ } <$fh>;

# transpose columns
my @cols;
for my $line (@lines) {
    my @chars = split //, $line;
    for my $i (0..$#chars) {
        push @{ $cols[$i] }, $chars[$i];
    }
}

my $p1 = "";
my $p2 = "";

for my $col (@cols) {
    my %cnt;
    $cnt{$_}++ for @$col;

    my @sorted = sort {
        $cnt{$b} <=> $cnt{$a}
        || $a cmp $b
    } keys %cnt;

    $p1 .= $sorted[0];
    $p2 .= $sorted[-1];
}

print "2016 day6: pl_ans_1: $p1\n";
print "2016 day6: pl_ans_2: $p2\n";

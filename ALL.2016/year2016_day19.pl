use strict;
use warnings;

open my $fh,"<",$ARGV[0] or die $!;
my $n = <$fh>; chomp $n;

sub p1 {
    my $n = shift;
    my $p = 1 << int(log($n)/log(2));
    return 2*($n-$p)+1;
}

sub p2 {
    my $p=1;
    $p*=3 while $p*3 <= $_[0];

    return $_[0] if $_[0]==$p;
    return $_[0]-$p if $_[0]<=2*$p;
    return 2*$_[0]-3*$p;
}

print "2016 day19: pl_ans_1: " . p1($n) . "\n";
print "2016 day19: pl_ans_2: " . p2($n) . "\n";

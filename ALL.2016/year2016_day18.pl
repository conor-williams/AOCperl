use strict;
use warnings;

open my $fh,"<",$ARGV[0] or die $!;
my $inp = <$fh>; chomp $inp;

sub gen {
    my $row = shift;
    my $n = "";
    for(my $i=0;$i<length($row);$i++){
        my $l = ($i==0)?".":substr($row,$i-1,1);
        my $c = substr($row,$i,1);
        my $r = ($i==length($row)-1)?".":substr($row,$i+1,1);

        my $trap =
            ($l eq "^" && $c eq "^" && $r eq ".") ||
            ($l eq "." && $c eq "^" && $r eq "^") ||
            ($l eq "^" && $c eq "." && $r eq ".") ||
            ($l eq "." && $c eq "." && $r eq "^");

        $n .= $trap ? "^" : ".";
    }
    return $n;
}

sub solve {
    my $rows = shift;
    my $row = $inp;
    my $safe = ($row =~ tr/././);

    for(1..$rows-1){
        $row = gen($row);
        $safe += ($row =~ tr/././);
    }
    return $safe;
}

print "2016 day18: pl_ans_1: " . solve(40) . "\n";
print "2016 day18: pl_ans_2: " . solve(400000) . "\n";

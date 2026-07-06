use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my $seed = <$fh>; chomp $seed;

sub dragon {
    my $s = shift;
    my $inv = $s;
    $inv =~ tr/01/10/;
    $inv = reverse $inv;
    return $s . "0" . $inv;
}

sub fill {
    my ($s,$len)=@_;
    while(length($s) < $len){
        $s = dragon($s);
    }
    return substr($s,0,$len);
}

sub checksum {
    my $s = shift;
    while(length($s)%2==0){
        my $n="";
        for(my $i=0;$i<length($s);$i+=2){
            $n .= (substr($s,$i,1) eq substr($s,$i+1,1)) ? "1" : "0";
        }
        $s=$n;
    }
    return $s;
}

my $d1 = fill($seed,272);
my $p1 = checksum($d1);

my $d2 = fill($seed,35651584);
my $p2 = checksum($d2);

print "2016 day16: pl_ans_1: $p1\n";
print "2016 day16: pl_ans_2: $p2\n";

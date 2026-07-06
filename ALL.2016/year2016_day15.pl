use strict;
use warnings;

open my $fh,"<",$ARGV[0] or die $!;
my @d;

while(<$fh>){
    my @p=split;
    push @d,[$p[3],$p[-1]];
}

sub ok{
    my $t=shift;
    for my $i(0..$#d){
        return 0 if(($d[$i][1]+$t+$i+1)%$d[$i][0]);
    }
    return 1;
}

my $t=0;
while(!ok($t)){ $t++; }

print "2016 day15: pl_ans_1: $t\n";

push @d,[11,0];

$t=0;
while(!ok($t)){ $t++; }

print "2016 day15: pl_ans_2: $t\n";

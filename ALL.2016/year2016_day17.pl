use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

open my $fh, "<", $ARGV[0] or die $!;
my $inp = <$fh>; chomp $inp;

my @open = qw(b c d e f);

sub open_dir {
    my ($x,$y,$path)=@_;
    my $h = md5_hex($inp . join("",@$path));

    my @res;

    if($y>0 && index("bcdef",substr($h,0,1))!=-1){
        push @res, [$x,$y-1,[@$path,"U"]];
    }
    if($y<3 && index("bcdef",substr($h,1,1))!=-1){
        push @res, [$x,$y+1,[@$path,"D"]];
    }
    if($x>0 && index("bcdef",substr($h,2,1))!=-1){
        push @res, [$x-1,$y,[@$path,"L"]];
    }
    if($x<3 && index("bcdef",substr($h,3,1))!=-1){
        push @res, [$x+1,$y,[@$path,"R"]];
    }

    return @res;
}

my @stack = ([0,0,[]]);
my @valid;

while(@stack){
    my $s = pop @stack;
    my ($x,$y,$p)=@$s;

    if($x==3 && $y==3){
        push @valid, join("",@$p);
        next;
    }

    push @stack, open_dir($x,$y,$p);
}

@valid = sort { length($a) <=> length($b) } @valid;

print "2016 day17: pl_ans_1: $valid[0]\n";
print "2016 day17: pl_ans_2: " . length($valid[-1]) . "\n";

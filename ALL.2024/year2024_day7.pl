use strict;
use warnings;


sub digits {
    my ($n)=@_;
    return length($n);
}


sub can_make {

    my ($target,$nums,$i,$value,$part2,$memo)=@_;


    return 1 if $i == @$nums && $value == $target;

    return 0 if $i == @$nums;


    # safe prune
    return 0 if $value > $target;


    my $key="$i,$value";

    return $memo->{$key}
        if exists $memo->{$key};


    my $n=$nums->[$i];


    # addition
    if (can_make(
        $target,
        $nums,
        $i+1,
        $value+$n,
        $part2,
        $memo
    )) {
        return $memo->{$key}=1;
    }



    # multiplication

    if (can_make(
        $target,
        $nums,
        $i+1,
        $value*$n,
        $part2,
        $memo
    )) {
        return $memo->{$key}=1;
    }



    # concatenation

    if ($part2) {

        my $concat =
            $value * (10 ** digits($n))
            + $n;


        if (can_make(
            $target,
            $nums,
            $i+1,
            $concat,
            $part2,
            $memo
        )) {
            return $memo->{$key}=1;
        }
    }


    return $memo->{$key}=0;
}



my $path=$ARGV[0];

open my $fh,"<",$path or die "$path: $!";


my @equations;


while (<$fh>) {

    chomp;

    next unless /\S/;


    my ($left,$right)=split /:/;


    my $target=int($left);


    my @nums=map {int($_)}
             grep {length}
             split /\s+/,$right;


    push @equations,[$target,\@nums];
}


close $fh;



my ($p1,$p2)=(0,0);



for my $eq (@equations) {

    my ($target,$nums)=@$eq;


    my %memo1;


    if (can_make(
        $target,
        $nums,
        1,
        $nums->[0],
        0,
        \%memo1
    )) {

        $p1 += $target;
        $p2 += $target;       # already valid for part 2
        next;
    }



    my %memo2;


    if (can_make(
        $target,
        $nums,
        1,
        $nums->[0],
        1,
        \%memo2
    )) {
        $p2 += $target;
    }
}



print "2024 day7: pl_ans_1: $p1\n";
print "2024 day7: pl_ans_2: $p2\n";

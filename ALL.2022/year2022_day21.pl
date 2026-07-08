#!/usr/bin/perl
use strict;
use warnings;


my $file=$ARGV[0];

open(my $fh,"<",$file) or die $!;

my %monkeys;


while(<$fh>) {

    chomp;
    next if $_ eq "";

    my ($name,$expr)=split(/: /,$_,2);

    my @p=split(/ /,$expr);

    if(@p==1) {
        $monkeys{$name}=int($p[0]);
    }
    else {
        $monkeys{$name}=[$p[0],$p[1],$p[2]];
    }
}

close($fh);



sub is_number {

    return !ref($_[0]);
}



sub eval_tree {

    my ($node,$m)=@_;

    my $v=$m->{$node};

    return $v if !ref($v);


    my ($a,$op,$b)=@$v;


    my $x=eval_tree($a,$m);
    my $y=eval_tree($b,$m);


    return $x+$y if $op eq "+";
    return $x-$y if $op eq "-";
    return $x*$y if $op eq "*";
    return int($x/$y) if $op eq "/";
}



sub eval_simple {

    my ($node,$m)=@_;


    return undef if $node eq "humn";


    my $v=$m->{$node};


    return $v if !ref($v);


    my ($a,$op,$b)=@$v;


    my $x=eval_simple($a,$m);
    my $y=eval_simple($b,$m);


    return undef if !defined($x) || !defined($y);


    return $x+$y if $op eq "+";
    return $x-$y if $op eq "-";
    return $x*$y if $op eq "*";
    return int($x/$y) if $op eq "/";
}



sub contains_humn {

    my ($node,$m)=@_;


    return 1 if $node eq "humn";


    my $v=$m->{$node};


    return 0 if !ref($v);


    my ($a,$op,$b)=@$v;


    return contains_humn($a,$m)
        || contains_humn($b,$m);
}



sub solve_reverse {

    my ($node,$value,$m)=@_;


    return $value if $node eq "humn";


    my ($a,$op,$b)=@{$m->{$node}};



    #
    # left side contains humn
    #

    if(contains_humn($a,$m)) {


        my $right=eval_simple($b,$m);


        if($op eq "+") {
            return solve_reverse(
                $a,$value-$right,$m
            );
        }


        if($op eq "-") {
            return solve_reverse(
                $a,$value+$right,$m
            );
        }


        if($op eq "*") {
            return solve_reverse(
                $a,int($value/$right),$m
            );
        }


        if($op eq "/") {
            return solve_reverse(
                $a,$value*$right,$m
            );
        }
    }



    #
    # right side contains humn
    #

    else {


        my $left=eval_simple($a,$m);


        if($op eq "+") {
            return solve_reverse(
                $b,$value-$left,$m
            );
        }


        if($op eq "-") {
            return solve_reverse(
                $b,$left-$value,$m
            );
        }


        if($op eq "*") {
            return solve_reverse(
                $b,int($value/$left),$m
            );
        }


        if($op eq "/") {
            return solve_reverse(
                $b,int($left/$value),$m
            );
        }
    }
}



# -------------------------
# Part 1
# -------------------------

my $p1=eval_tree("root",\%monkeys);



# -------------------------
# Part 2
# -------------------------

my ($left,$op,$right)=@{$monkeys{"root"}};


my ($target,$expr);


if(contains_humn($left,\%monkeys)) {

    $target=eval_simple($right,\%monkeys);
    $expr=$left;

}
else {

    $target=eval_simple($left,\%monkeys);
    $expr=$right;
}


my $p2=solve_reverse(
    $expr,
    $target,
    \%monkeys
);



print "2022 day21: pl_ans_1: $p1\n";
print "2022 day21: pl_ans_2: $p2\n";

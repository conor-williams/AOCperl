use strict;
use warnings;


# ------------------------------------------------------------
# Parse input
# ------------------------------------------------------------

my $file = shift;

open(my $fh,"<",$file) or die $!;

my $text = do {
    local $/;
    <$fh>;
};

close($fh);


my @blocks = split(/\n\n/, $text);


my @p1;
my @p2;


foreach my $line (split(/\n/,$blocks[0])) {

    next if $line =~ /Player/;

    push @p1,int($line);

}


foreach my $line (split(/\n/,$blocks[1])) {

    next if $line =~ /Player/;

    push @p2,int($line);

}



# ------------------------------------------------------------
# Score
# ------------------------------------------------------------

sub score {

    my @deck=@_;

    my $sum=0;
    my $mult=1;


    foreach my $card (reverse @deck) {

        $sum += $mult*$card;

        $mult++;

    }

    return $sum;
}



# ------------------------------------------------------------
# Part 1 Combat
# ------------------------------------------------------------

sub combat {

    my (@a)=@{$_[0]};
    my (@b)=@{$_[1]};


    while (@a && @b) {

        my $x=shift @a;
        my $y=shift @b;


        if ($x>$y) {

            push @a,$x,$y;

        }
        else {

            push @b,$y,$x;

        }

    }


    return @a ? @a : @b;
}



my @winner1 = combat(\@p1,\@p2);

my $ans1 = score(@winner1);



# ------------------------------------------------------------
# Recursive Combat
# ------------------------------------------------------------

sub recursive_combat {


    my (@a)=@{$_[0]};
    my (@b)=@{$_[1]};


    my %seen;


    while (@a && @b) {


        my $state =
            join(",",@a)
            .
            "|"
            .
            join(",",@b);


        if ($seen{$state}) {

            return (1,\@a);

        }

        $seen{$state}=1;



        my $x=shift @a;
        my $y=shift @b;


        my $winner;


        if (@a >= $x && @b >= $y) {


            my @sub1=@a[0..$x-1];
            my @sub2=@b[0..$y-1];


            ($winner)=recursive_combat(
                \@sub1,
                \@sub2
            );


        }
        else {

            $winner =
                $x>$y ? 1 : 2;

        }



        if ($winner==1) {

            push @a,$x,$y;

        }
        else {

            push @b,$y,$x;

        }

    }


    if (@a) {

        return (1,\@a);

    }
    else {

        return (2,\@b);

    }

}



my ($winner2,$deck2)=recursive_combat(
    \@p1,
    \@p2
);


my $ans2=score(@$deck2);



print "2020 day22: pl_ans_1: $ans1\n";
print "2020 day22: pl_ans_2: $ans2\n";

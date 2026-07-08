use strict;
use warnings;


my $file = shift;

open(my $fh,"<",$file) or die $!;


my @foods;

while (<$fh>) {

    chomp;

    next if $_ eq "";

    push @foods,$_;

}

close($fh);



# ------------------------------------------------------------
# Parse foods
# ------------------------------------------------------------

my %ingredient_count;

my %allergen_map;


foreach my $line (@foods) {


    my ($ing,$all);

    if ($line =~ /(.*) \(contains (.*)\)/) {

        $ing=$1;
        $all=$2;

    }
    else {

        $ing=$line;
        $all="";

    }


    my @ingredients=split(/ /,$ing);


    foreach my $i (@ingredients) {

        $ingredient_count{$i}++;

    }


    if ($all ne "") {

        my @allergens=split(/, /,$all);


        foreach my $a (@allergens) {


            my %set;

            foreach my $i (@ingredients) {

                $set{$i}=1;

            }


            if (exists $allergen_map{$a}) {


                my %old=%{$allergen_map{$a}};

                my %new;


                foreach my $k (keys %old) {

                    $new{$k}=1
                        if exists $set{$k};

                }

                $allergen_map{$a}=\%new;

            }
            else {

                $allergen_map{$a}=\%set;

            }

        }

    }

}



# ------------------------------------------------------------
# Resolve allergens
# ------------------------------------------------------------

my %resolved;


while (keys %allergen_map) {


    foreach my $a (keys %allergen_map) {


        my @possible =
            keys %{$allergen_map{$a}};


        if (@possible == 1) {


            my $ingredient=$possible[0];

            $resolved{$a}=$ingredient;


            delete $allergen_map{$a};


            foreach my $other (keys %allergen_map) {

                delete $allergen_map{$other}{$ingredient};

            }


            last;

        }

    }

}



# ------------------------------------------------------------
# Part 1
# ------------------------------------------------------------

my %dangerous;


foreach my $a (keys %resolved) {

    $dangerous{$resolved{$a}}=1;

}


my $p1=0;


foreach my $i (keys %ingredient_count) {

    $p1 += $ingredient_count{$i}
        unless exists $dangerous{$i};

}



# ------------------------------------------------------------
# Part 2
# ------------------------------------------------------------

my @sorted =
    sort keys %resolved;


my @canonical;


foreach my $a (@sorted) {

    push @canonical,$resolved{$a};

}


my $p2=join(",",@canonical);



print "2020 day21: pl_ans_1: $p1\n";
print "2020 day21: pl_ans_2: $p2\n";

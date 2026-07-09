#!/usr/bin/env perl

use strict;
use warnings;


my $DAY = 24;



sub is_input {

    my ($operand)=@_;

    return substr($operand,0,1) eq "x" ||
           substr($operand,0,1) eq "y";
}



# ---------------- PART 2 ----------------

sub part2 {

    my ($values,$operations)=@_;


    my %use_map;


    for my $op (@$operations) {

        my ($left,$operator,$right,$result)=@$op;

        push @{$use_map{$left}},  $op;
        push @{$use_map{$right}}, $op;
    }


    my %swapped;


    for my $operation (@$operations) {

        my ($left,$op,$right,$result)=@$operation;


        # Special-case first and last bits
        next if $result eq "z45" || $left eq "x00";


        if ($op eq "XOR") {


            if (is_input($left)) {


                if (!is_input($right)) {
                    $swapped{$result}=1;
                }


                if (substr($result,0,1) eq "z"
                    && $result ne "z00") {

                    $swapped{$result}=1;
                }


                my $usage=$use_map{$result} // [];

                my @using_ops =
                    map { $_->[1] } @$usage;


                my @sorted=sort @using_ops;


                if ($result ne "z00" &&
                    join(",",@sorted) ne "AND,XOR") {

                    $swapped{$result}=1;
                }

            }
            else {

                if (substr($result,0,1) ne "z") {
                    $swapped{$result}=1;
                }
            }


        }
        elsif ($op eq "AND") {


            if (is_input($left)) {

                if (!is_input($right)) {
                    $swapped{$result}=1;
                }
            }


            my $usage=$use_map{$result} // [];

            my @using_ops =
                map { $_->[1] } @$usage;


            if (join(",",@using_ops) ne "OR") {
                $swapped{$result}=1;
            }


        }
        elsif ($op eq "OR") {


            if (is_input($left) || is_input($right)) {
                $swapped{$result}=1;
            }


            my $usage=$use_map{$result} // [];

            my @using_ops =
                sort map { $_->[1] } @$usage;


            if (join(",",@using_ops) ne "AND,XOR") {
                $swapped{$result}=1;
            }


        }
        else {

            print "unknown op\n";
        }
    }


    return join(",",
        sort keys %swapped
    );
}



# ---------------- PART 1 ----------------

sub part1 {

    my ($values,$operations)=@_;

    my $results=apply_operations(
        $values,
        $operations
    );

    return sum_zvalues($results);
}



sub apply_operations {

    my ($values,$operations)=@_;


    my %mem=%$values;


    while (1) {

        my $did_operation=0;


        for my $op (@$operations) {

            my ($left,$operator,$right,$result)=@$op;


            next if exists $mem{$result};


            next unless exists $mem{$left}
                     && exists $mem{$right};


            $mem{$result} =
                do_op(
                    $mem{$left},
                    $operator,
                    $mem{$right}
                );


            $did_operation=1;
        }


        last unless $did_operation;
    }


    return \%mem;
}



sub do_op {

    my ($left,$op,$right)=@_;


    if ($op eq "AND") {
        return $left && $right;
    }

    if ($op eq "OR") {
        return $left || $right;
    }

    if ($op eq "XOR") {
        return $left ^ $right;
    }


    die "unknown operation $op";
}



sub sum_zvalues {

    my ($results)=@_;


    my @keys =
        sort grep {
            /^z/
        } keys %$results;


    @keys=reverse @keys;


    my $result=0;


    for my $k (@keys) {

        $result <<= 1;
        $result += $results->{$k};
    }


    return $result;
}



# ---------------- PARSE ----------------

sub parse {

    my ($lines)=@_;


    my %values;
    my @operations;


    for my $line (@$lines) {

        next unless length $line;


        if ($line =~ /:/) {

            my ($name,$rest)=split /:/,$line,2;

            $values{$name}=int($rest);

        }
        elsif ($line =~ /->/) {

            my @parts=split / /,$line;


            push @operations,
                [
                    $parts[0],
                    $parts[1],
                    $parts[2],
                    $parts[4]
                ];
        }
    }


    return (\%values,\@operations);
}



# ---------------- MAIN ----------------

my $file=$ARGV[0] // "example";


open my $fh,'<',$file or die "$file: $!";

my @lines=<$fh>;

close $fh;


chomp @lines;


my ($values,$operations)=parse(\@lines);


print "2024 day24: pl_ans_1: ",
      part1($values,$operations),
      "\n";


print "2024 day24: pl_ans_2 (maybe): ",
      part2($values,$operations),
      "\n";

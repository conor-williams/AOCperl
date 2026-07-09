#!/usr/bin/env perl

use strict;
use warnings;


# ============================================================
# PARSE
# ============================================================

sub parse {

    my ($lines)=@_;


    my @patterns;


    # first line = available patterns

    for my $p (split /,/, $lines->[0]) {

        $p =~ s/^\s+//;
        $p =~ s/\s+$//;

        push @patterns, scalar reverse $p;
    }



    my @targets;


    for my $i (1 .. $#$lines) {

        my $line=$lines->[$i];

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next if $line eq "";


        my $rev = scalar reverse $line;

        push @targets, [$rev,$line];
    }


    return (\@patterns,\@targets);
}



# ============================================================
# PART 1
# ============================================================

sub can_form {

    my ($s,$pos,$patterns,$memo)=@_;


    return 1 if $pos == length($s);


    return $memo->{$pos}
        if exists $memo->{$pos};



    for my $p (@$patterns) {


        my $len=length($p);


        next if $pos+$len > length($s);


        if (substr($s,$pos,$len) eq $p) {


            if (can_form(
                    $s,
                    $pos+$len,
                    $patterns,
                    $memo
                )) {

                $memo->{$pos}=1;
                return 1;
            }
        }
    }


    $memo->{$pos}=0;

    return 0;
}



# ============================================================
# PART 2
# ============================================================

sub count_ways {

    my ($s,$pos,$patterns,$memo)=@_;


    return 1 if $pos == length($s);


    return $memo->{$pos}
        if exists $memo->{$pos};



    my $total=0;


    for my $p (@$patterns) {


        my $len=length($p);


        next if $pos+$len > length($s);



        if (substr($s,$pos,$len) eq $p) {


            $total += count_ways(
                $s,
                $pos+$len,
                $patterns,
                $memo
            );
        }
    }


    $memo->{$pos}=$total;


    return $total;
}



# ============================================================
# SOLVE
# ============================================================

sub solve {


    my ($lines)=@_;


    my ($patterns,$targets)=parse($lines);


    my $p1=0;
    my $p2=0;



    for my $target (@$targets) {


        my ($rev,$original)=@$target;



        if (can_form(
                $rev,
                0,
                $patterns,
                {}
            )) {


            $p1++;


            $p2 += count_ways(
                $rev,
                0,
                $patterns,
                {}
            );
        }
    }


    return ($p1,$p2);
}



# ============================================================
# MAIN
# ============================================================

my $file=$ARGV[0];

open my $fh,"<",$file
    or die "$file: $!";


my @lines=<$fh>;

close $fh;


chomp @lines;



my ($p1,$p2)=solve(\@lines);



print "2024 day19: pl_ans_1: $p1\n";
print "2024 day19: pl_ans_2: $p2\n";

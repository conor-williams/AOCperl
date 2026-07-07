#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Read magic number
# -------------------------------------------------

my $file = shift @ARGV
    or die "Usage: $0 input.txt\n";


open(my $fh, '<', $file)
    or die "Cannot open $file: $!";


my @lines = <$fh>;

close($fh);


my ($magic_number) =
    $lines[8] =~ /(\d+)/;



# -------------------------------------------------
# Activation system
# -------------------------------------------------

sub run_activation_system
{
    my ($magic_number, $part1) = @_;


    my %seen;


    my $c = 0;


    my $last_unique_c = -1;



    while (1)
    {
        my $a = $c | 65536;


        $c = $magic_number;



        while (1)
        {
            $c =
                ((($c + ($a & 255))
                    & 16777215)
                    * 65899)
                & 16777215;



            if (256 > $a)
            {
                if ($part1)
                {
                    return $c;
                }
                else
                {
                    if (!$seen{$c})
                    {
                        $seen{$c}=1;

                        $last_unique_c=$c;

                        last;
                    }
                    else
                    {
                        return $last_unique_c;
                    }
                }
            }
            else
            {
                $a = int($a / 256);
            }
        }
    }
}



# -------------------------------------------------
# Answers
# -------------------------------------------------

my $p1 =
    run_activation_system(
        $magic_number,
        1
    );


my $p2 =
    run_activation_system(
        $magic_number,
        0
    );


print "2018 day21: pl_ans_1: $p1\n";
print "2018 day21: pl_ans_2: $p2\n";

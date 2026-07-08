use strict;
use warnings;


# ------------------------------------------------------------
# Part 1 evaluator
# ------------------------------------------------------------

sub eval1 {

    my @tokens = @_;

    my $res = int($tokens[0]);
    my $i = 1;

    while ($i < scalar(@tokens)) {

        my $op = $tokens[$i];
        my $val = int($tokens[$i+1]);

        if ($op eq "+") {
            $res += $val;
        }
        else {
            $res *= $val;
        }

        $i += 2;
    }

    return $res;
}



# ------------------------------------------------------------
# Token parser
# ------------------------------------------------------------

sub parse {

    my ($expr) = @_;

    my @tokens;

    while ($expr =~ /(\d+|[+*()])/g) {
        push @tokens, $1;
    }

    return @tokens;
}



# ------------------------------------------------------------
# Reduce parentheses
# ------------------------------------------------------------

sub reduce_parens {

    my ($tokens_ref, $mode) = @_;

    my @tokens = @$tokens_ref;

    my @stack;


    foreach my $t (@tokens) {

        if ($t eq ")") {

            my @sub;

            while (@stack && $stack[-1] ne "(") {
                push @sub, pop @stack;
            }

            pop @stack;       # remove '('

            @sub = reverse @sub;


            my $val;

            if ($mode == 1) {
                $val = eval1(@sub);
            }
            else {
                $val = eval2(@sub);
            }


            push @stack, "$val";

        }
        else {

            push @stack, $t;

        }
    }


    return @stack;
}



# ------------------------------------------------------------
# Part 2 evaluator
# + before *
# ------------------------------------------------------------

sub eval2 {

    my @tokens = @_;


    while (grep { $_ eq "+" } @tokens) {


        my $i;

        for ($i=0; $i<@tokens; $i++) {
            last if $tokens[$i] eq "+";
        }


        my $val =
            int($tokens[$i-1]) +
            int($tokens[$i+1]);


        splice(@tokens, $i-1, 3, "$val");

    }


    my $res = 1;


    foreach my $t (@tokens) {

        next if $t eq "*";

        $res *= int($t);
    }


    return $res;
}



# ------------------------------------------------------------
# Solve
# ------------------------------------------------------------

sub solve {

    my ($lines_ref, $mode) = @_;

    my $total = 0;


    foreach my $line (@$lines_ref) {


        my @tokens = parse($line);


        while (grep { $_ eq "(" } @tokens) {

            @tokens = reduce_parens(\@tokens,$mode);

        }


        if ($mode == 1) {
            $total += eval1(@tokens);
        }
        else {
            $total += eval2(@tokens);
        }

    }


    return $total;
}



# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

my $file = shift;


open(my $fh,"<",$file) or die $!;

my @lines;

while (<$fh>) {

    chomp;

    push @lines,$_ if $_ ne "";

}

close($fh);



my $p1 = solve(\@lines,1);
my $p2 = solve(\@lines,2);


print "2020 day18: pl_ans_1: $p1\n";
print "2020 day18: pl_ans_2: $p2\n";

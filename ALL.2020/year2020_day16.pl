use strict;
use warnings;


# ------------------------------------------------------------
# Read input
# ------------------------------------------------------------

my $file = shift;

open(my $fh, "<", $file) or die $!;

local $/;
my $text = <$fh>;

close($fh);


# ------------------------------------------------------------
# Parse input
# ------------------------------------------------------------

my ($rules_text, $your_text, $nearby_text) =
    split(/\n\n/, $text);


my %rules;


for my $line (split(/\n/, $rules_text)) {

    my ($name, $a, $b, $c, $d) =
        $line =~ /^(.+): (\d+)-(\d+) or (\d+)-(\d+)$/;

    $rules{$name} = [
        [$a, $b],
        [$c, $d]
    ];
}


my @your;

for my $v (split(/,/, (split(/\n/, $your_text))[1])) {
    push @your, int($v);
}


my @nearby;

my @near_lines = split(/\n/, $nearby_text);

shift @near_lines;


for my $line (@near_lines) {

    my @t = map { int($_) } split(/,/, $line);

    push @nearby, \@t;
}



# ------------------------------------------------------------
# Check value against any rule
# ------------------------------------------------------------

sub valid_for_any_rule {

    my ($value, $rules_ref) = @_;

    foreach my $ranges (values %$rules_ref) {

        foreach my $r (@$ranges) {

            my ($a, $b) = @$r;

            return 1
                if $value >= $a && $value <= $b;
        }
    }

    return 0;
}



sub valid_ticket {

    my ($ticket, $rules_ref) = @_;

    foreach my $v (@$ticket) {

        return 0
            unless valid_for_any_rule($v, $rules_ref);
    }

    return 1;
}



# ------------------------------------------------------------
# Part 1
# ------------------------------------------------------------

my $error_rate = 0;


for my $ticket (@nearby) {

    for my $v (@$ticket) {

        if (!valid_for_any_rule($v, \%rules)) {

            $error_rate += $v;
        }
    }
}


print "2020 day16: pl_ans_1: $error_rate\n";



# ------------------------------------------------------------
# Part 2 determine fields
# ------------------------------------------------------------

my @valid_tickets;


for my $t (@nearby) {

    push @valid_tickets, $t
        if valid_ticket($t, \%rules);
}


my $field_count = scalar @your;


my %possible;


foreach my $name (keys %rules) {

    $possible{$name} = {};

    for my $i (0 .. $field_count-1) {

        $possible{$name}{$i} = 1;
    }
}



foreach my $name (keys %rules) {


    my $ranges = $rules{$name};


    for my $pos (0 .. $field_count-1) {


        foreach my $ticket (@valid_tickets) {


            my $v = $ticket->[$pos];


            my $ok = 0;


            foreach my $r (@$ranges) {

                my ($a,$b) = @$r;

                if ($v >= $a && $v <= $b) {

                    $ok = 1;
                    last;
                }
            }


            if (!$ok) {

                delete $possible{$name}{$pos};

                last;
            }
        }
    }
}



# ------------------------------------------------------------
# Resolve fields
# ------------------------------------------------------------

my %mapping;


while (keys %possible) {


    foreach my $name (keys %possible) {


        my @p = keys %{$possible{$name}};


        if (@p == 1) {


            my $pos = $p[0];


            $mapping{$name} = $pos;


            delete $possible{$name};


            foreach my $other (keys %possible) {

                delete $possible{$other}{$pos};
            }


            last;
        }
    }
}



# ------------------------------------------------------------
# Part 2 answer
# ------------------------------------------------------------

my $result = 1;


foreach my $name (keys %mapping) {


    if ($name =~ /^departure/) {

        $result *= $your[$mapping{$name}];
    }
}


print "2020 day16: pl_ans_2: $result\n";

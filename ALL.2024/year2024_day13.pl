use strict;
use warnings;


sub solve_machine {

    my ($ax,$ay,$bx,$by,$px,$py)=@_;


    my $det = $ax*$by - $ay*$bx;

    return [] if $det == 0;


    my $a_num = $px*$by - $py*$bx;
    my $b_num = $ax*$py - $ay*$px;


    return [] if $a_num % $det != 0;
    return [] if $b_num % $det != 0;


    my $a = int($a_num / $det);
    my $b = int($b_num / $det);


    return [$a,$b];
}

sub parse {

    my ($lines,$offset)=@_;

    my @machines;


    my $text = join "\n", @$lines;

    my @nums = ($text =~ /\d+/g);


    for (my $i=0; $i<@nums; $i+=6) {

        my ($ax,$ay,$bx,$by,$px,$py) =
            @nums[$i .. $i+5];


        push @machines,
        [
            int($ax),
            int($ay),
            int($bx),
            int($by),
            int($px)+$offset,
            int($py)+$offset
        ];
    }


    return \@machines;
}



sub solve {

    my ($machines)=@_;

    my $total=0;


    for my $m (@$machines) {

        my ($ax,$ay,$bx,$by,$px,$py)=@$m;


        my $res = solve_machine(
            $ax,$ay,
            $bx,$by,
            $px,$py
        );


        next unless @$res;


        my ($a,$b)=@$res;


        $total += 3*$a + $b;
    }


    return $total;
}
my $path = $ARGV[0];

open my $fh, '<', $path
    or die "$path: $!";


my @lines = <$fh>;

close $fh;



# ---------------- Part 1 ----------------

my $machines1 = parse(\@lines,0);

my $p1 = solve($machines1);



# ---------------- Part 2 ----------------

my $machines2 = parse(\@lines,10000000000000);

my $p2 = solve($machines2);



print "2024 day13: pl_ans_1: $p1\n";
print "2024 day13: pl_ans_2: $p2\n";

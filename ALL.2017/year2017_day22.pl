use strict;
use warnings;
use Data::Dumper;

my @dirs = (
    [-1,0],
    [0,1],
    [1,0],
    [0,-1]
);

sub turn_left {
    my ($d) = @_;
    return ($d - 1) % 4;
}

sub turn_right {
    my ($d) = @_;
    return ($d + 1) % 4;
}

sub reverse_dir {
    my ($d) = @_;
    return ($d + 2) % 4;
}


sub parse_grid {
    my (@lines) = @_;

    my %grid;
    my $n = scalar(@lines);
    my $offset = int($n / 2);

    for my $y (0 .. $#lines) {
        my @chars = split //, $lines[$y];

        for my $x (0 .. $#chars) {
            if ($chars[$x] eq "#") {
                $grid{($y-$offset).",".($x-$offset)} = "infected";
            }
        }
    }

    return \%grid;
}


sub simulate_part1 {
    my ($input,$bursts) = @_;

    my %grid = %$input;

    my $x = 0;
    my $y = 0;
    my $d = 0;
    my $infections = 0;

    for (1 .. $bursts) {

        my $key = "$x,$y";

        if (exists $grid{$key} && $grid{$key} eq "infected") {
            $d = turn_right($d);
            $grid{$key} = "clean";
        }
        else {
            $d = turn_left($d);
            $grid{$key} = "infected";
            $infections++;
        }

        $x += $dirs[$d]->[0];
        $y += $dirs[$d]->[1];
    }

    return $infections;
}


sub simulate_part2 {
    my ($input,$bursts) = @_;

    my %grid = %$input;

    my $x = 0;
    my $y = 0;
    my $d = 0;
    my $infections = 0;

    for (1 .. $bursts) {

        my $key = "$x,$y";

        my $state = exists $grid{$key} ? $grid{$key} : "clean";

        if ($state eq "clean") {
            $d = turn_left($d);
            $grid{$key} = "weakened";
        }
        elsif ($state eq "weakened") {
            $grid{$key} = "infected";
            $infections++;
        }
        elsif ($state eq "infected") {
            $d = turn_right($d);
            $grid{$key} = "flagged";
        }
        elsif ($state eq "flagged") {
            $d = reverse_dir($d);
            $grid{$key} = "clean";
        }

        $x += $dirs[$d]->[0];
        $y += $dirs[$d]->[1];
    }

    return $infections;
}


sub main {
    open(my $fh,"<",$ARGV[0]) or die $!;

    my @lines = <$fh>;
    chomp @lines;

    my $grid = parse_grid(@lines);

    print "2017 day22: pl_ans_1: ", simulate_part1($grid,10000), "\n";
    print "2017 day22: pl_ans_2: ", simulate_part2($grid,10000000), "\n";
}

main();

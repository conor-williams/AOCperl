use strict;
use warnings;


my $file = $ARGV[0];

open(my $fh, "<", $file) or die "Cannot open $file";

my $text = "";

while (<$fh>) {
    $text .= $_;
}

close($fh);



sub parse {

    my ($text) = @_;

    my @grid = split(/\n/, $text);


    my $w = 0;

    foreach my $row (@grid) {

        my $len = length($row);

        if ($len > $w) {
            $w = $len;
        }
    }


    for (my $i = 0; $i < scalar(@grid); $i++) {

        while (length($grid[$i]) < $w) {

            $grid[$i] .= " ";
        }
    }


    return @grid;
}



sub solve {

    my ($text) = @_;

    my @grid = parse($text);


    my $h = scalar(@grid);
    my $w = length($grid[0]);


    my $x = index($grid[0], "|");

    my $y = 0;


    my $dx = 0;
    my $dy = 1;


    my @letters;

    my $steps = 0;



    while (1) {

        my $c = substr($grid[$y], $x, 1);


        last if $c eq " ";


        if ($c =~ /[A-Za-z]/) {

            push @letters, $c;
        }



        if ($c eq "+") {


            my @dirs = (
                [1,0],
                [-1,0],
                [0,1],
                [0,-1]
            );


            foreach my $dir (@dirs) {

                my ($ndx, $ndy) = @$dir;


                my $nx = $x + $ndx;
                my $ny = $y + $ndy;


                next if $ndx == -$dx && $ndy == -$dy;


                if ($nx >= 0 && $nx < $w &&
                    $ny >= 0 && $ny < $h) {


                    my $next = substr($grid[$ny], $nx, 1);


                    if ($next ne " ") {

                        $dx = $ndx;
                        $dy = $ndy;

                        last;
                    }
                }
            }
        }



        $x += $dx;
        $y += $dy;

        $steps++;
    }


    return (join("", @letters), $steps);
}



my ($p1, $p2) = solve($text);


print "2017 day19: pl_ans_1: $p1\n";
print "2017 day19: pl_ans_2: $p2\n";

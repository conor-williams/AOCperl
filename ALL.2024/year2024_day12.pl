use strict;
use warnings;


sub neighbors {
    my ($x, $y) = @_;

    return (
        [$x+1, $y],
        [$x-1, $y],
        [$x, $y+1],
        [$x, $y-1],
    );
}


sub flood {
    my ($grid, $sx, $sy, $seen) = @_;

    my $h = @$grid;
    my $w = @{$grid->[0]};

    my $ch = $grid->[$sy][$sx];

    my @q = ([$sx, $sy]);

    my %region;


    while (@q) {

        my ($x, $y) = @{shift @q};

        my $key = "$x,$y";

        next if $seen->{$key};

        $seen->{$key} = 1;
        $region{$key} = 1;


        for my $n (neighbors($x,$y)) {

            my ($nx,$ny) = @$n;

            next if $nx < 0 || $nx >= $w;
            next if $ny < 0 || $ny >= $h;

            if ($grid->[$ny][$nx] eq $ch) {

                push @q, [$nx,$ny]
                    unless $seen->{"$nx,$ny"};
            }
        }
    }

    return \%region;
}


sub perimeter {
    my ($region) = @_;

    my $p = 0;


    for my $key (keys %$region) {

        my ($x,$y) = split /,/, $key;

        for my $n (neighbors($x,$y)) {

            my ($nx,$ny) = @$n;

            $p++ unless exists $region->{"$nx,$ny"};
        }
    }

    return $p;
}


sub count_sides {

    my ($region) = @_;

    my %edges;


    for my $key (keys %$region) {

        my ($x,$y) = split /,/, $key;

        for my $e (
            [0,-1,"U"],
            [0,1,"D"],
            [-1,0,"L"],
            [1,0,"R"]
        ) {

            my ($dx,$dy,$dir) = @$e;

            unless (exists $region->{($x+$dx).",".($y+$dy)}) {

                push @{$edges{"$dx,$dy"}}, [$x,$y];
            }
        }
    }


    my $sides = 0;


    for my $dir (keys %edges) {

        my %cells;

        $cells{"$_->[0],$_->[1]"} = 1
            for @{$edges{$dir}};


        my %seen;


        for my $cell (keys %cells) {

            next if $seen{$cell};

            $sides++;


            my @q = ([split /,/, $cell]);

            while (@q) {

                my ($cx,$cy) = @{shift @q};

                my $k = "$cx,$cy";

                next if $seen{$k};

                $seen{$k} = 1;


                for my $n (neighbors($cx,$cy)) {

                    my ($nx,$ny) = @$n;

                    my $nk = "$nx,$ny";

                    push @q, [$nx,$ny]
                        if $cells{$nk};
                }
            }
        }
    }

    return $sides;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

my @grid;

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    push @grid, [split //];
}

close $fh;


my $h = @grid;
my $w = @{$grid[0]};


my %seen;

my ($p1,$p2) = (0,0);


for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        next if $seen{"$x,$y"};

        my $region = flood(\@grid,$x,$y,\%seen);

        my $area = scalar keys %$region;

        $p1 += $area * perimeter($region);
        $p2 += $area * count_sides($region);
    }
}


print "2024 day12: pl_ans_1: $p1\n";
print "2024 day12: pl_ans_2: $p2\n";

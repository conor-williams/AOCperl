use strict;
use warnings;


# --------------------------------------------------
# simulation
# --------------------------------------------------

sub simulate {

    my ($grid,$sx,$sy,$ox,$oy,$need_path)=@_;


    my $h=@$grid;
    my $w=@{$grid->[0]};


    my ($x,$y)=($sx,$sy);


    # 0=N 1=E 2=S 3=W
    my $dir=0;


    my @dx=(0,1,0,-1);
    my @dy=(-1,0,1,0);


    my %visited;
    my %states;


    while (1) {


        # outside grid
        return (\%visited,0)
            if $x<0 || $x>=$w || $y<0 || $y>=$h;



        # state packed into integer
        my $state =
            (($y*$w+$x)<<2) | $dir;


        if (exists $states{$state}) {
            return (\%visited,1);
        }


        $states{$state}=1;


        if ($need_path) {
            $visited{$y*$w+$x}=1;
        }



        my $nx=$x+$dx[$dir];
        my $ny=$y+$dy[$dir];


        if (
            $nx>=0 && $nx<$w &&
            $ny>=0 && $ny<$h
        ) {

            if (
                $grid->[$ny][$nx] eq "#" ||
                (
                    defined $ox &&
                    $nx==$ox &&
                    $ny==$oy
                )
            ) {

                # turn right
                $dir=($dir+1)%4;

            }
            else {

                ($x,$y)=($nx,$ny);
            }

        }
        else {

            ($x,$y)=($nx,$ny);
        }
    }
}



# --------------------------------------------------
# read input
# --------------------------------------------------

my $path=$ARGV[0];


open my $fh,"<",$path or die "$path: $!";


my @grid;

my ($sx,$sy);


while (<$fh>) {

    chomp;

    next unless length;


    my @row=split //;


    for my $x (0..$#row) {

        if ($row[$x] eq "^") {

            ($sx,$sy)=($x,scalar(@grid));

            $row[$x]=".";
        }
    }


    push @grid,\@row;
}


close $fh;



# --------------------------------------------------
# Part 1
# --------------------------------------------------

my ($visited,$loop)=simulate(
    \@grid,
    $sx,
    $sy,
    undef,
    undef,
    1
);


my $p1=scalar keys %$visited;



# --------------------------------------------------
# Part 2
# --------------------------------------------------

my $p2=0;


for my $key (keys %$visited) {


    my $x=$key % @{$grid[0]};
    my $y=int($key/@{$grid[0]});


    next if $x==$sx && $y==$sy;


    my (undef,$loop)=simulate(
        \@grid,
        $sx,
        $sy,
        $x,
        $y,
        0
    );


    $p2++
        if $loop;
}



print "2024 day6: pl_ans_1: $p1\n";
print "2024 day6: pl_ans_2: $p2\n";

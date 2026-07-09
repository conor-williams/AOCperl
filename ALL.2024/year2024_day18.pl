use strict;
use warnings;


sub bfs {
    my ($blocked, $size) = @_;

    my ($sx,$sy) = (0,0);
    my ($ex,$ey) = ($size,$size);


    my @q = ([$sx,$sy,0]);
    my %seen = ("$sx,$sy" => 1);


    while (@q) {

        my ($x,$y,$d) = @{shift @q};


        return $d if $x == $ex && $y == $ey;


        for my $dir (
            [1,0],
            [-1,0],
            [0,1],
            [0,-1]
        ) {

            my ($dx,$dy)=@$dir;

            my ($nx,$ny)=($x+$dx,$y+$dy);


            next if $nx < 0 || $nx > $size;
            next if $ny < 0 || $ny > $size;


            next if $blocked->{"$nx,$ny"};
            next if $seen{"$nx,$ny"};


            $seen{"$nx,$ny"}=1;

            push @q, [$nx,$ny,$d+1];
        }
    }


    return undef;
}


my $path=$ARGV[0];

open my $fh,'<',$path or die "$path: $!";

my @coords;

while (<$fh>) {

    chomp;

    next unless /\S/;

    my ($x,$y)=split /,/;

    push @coords,[$x,$y];
}

close $fh;


my $size=70;
my $start_bytes=1024;


my %blocked;

for my $i (0 .. $start_bytes-1) {

    my ($x,$y)=@{$coords[$i]};

    $blocked{"$x,$y"}=1;
}


# Part 1

my $p1=bfs(\%blocked,$size);


# Part 2

my ($lo,$hi)=($start_bytes,scalar @coords);


while ($lo < $hi) {

    my $mid=int(($lo+$hi)/2);

    my %test;

    for my $i (0 .. $mid-1) {

        my ($x,$y)=@{$coords[$i]};

        $test{"$x,$y"}=1;
    }


    if (!defined bfs(\%test,$size)) {
        $hi=$mid;
    }
    else {
        $lo=$mid+1;
    }
}


my ($x,$y)=@{$coords[$lo-1]};

my $p2="$x,$y";


print "2024 day18: pl_ans_1: $p1\n";
print "2024 day18: pl_ans_2: $p2\n";

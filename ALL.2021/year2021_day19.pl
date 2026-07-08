use strict;
use warnings;
use List::Util qw(max);


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @scanners;
my @current;

while (<$fh>) {
    chomp;

    if (/^---/) {
        @current = ();
    }
    elsif (/^\s*$/) {
        push @scanners, [@current] if @current;
    }
    else {
        my @p = split /,/;
        push @current, [map { int($_) } @p];
    }
}

push @scanners, [@current] if @current;

close $fh;



# --------------------------------------------------
# Generate 24 valid rotations
# --------------------------------------------------

sub rotations {

    my @rots;

    my @perms = (
        [0,1,2],
        [0,2,1],
        [1,0,2],
        [1,2,0],
        [2,0,1],
        [2,1,0],
    );


    my @signs = (
        [-1,-1,-1],
        [-1,-1,1],
        [-1,1,-1],
        [-1,1,1],
        [1,-1,-1],
        [1,-1,1],
        [1,1,-1],
        [1,1,1],
    );


    for my $p (@perms) {

        for my $s (@signs) {

            my $v1 = [
                $s->[0] * (1 == $p->[0]),
                $s->[1] * (1 == $p->[1]),
                $s->[2] * (1 == $p->[2])
            ];

            my $v2 = [
                $s->[0] * (1 == $p->[0]),
                $s->[1] * (1 == $p->[1]),
                $s->[2] * (1 == $p->[2])
            ];


            my @basis = (
                [1,0,0],
                [0,1,0],
                [0,0,1]
            );


            my $a = rotate_point($basis[0],$p,$s);
            my $b = rotate_point($basis[1],$p,$s);
            my $c = rotate_point($basis[2],$p,$s);


            my $cross = [
                $a->[1]*$b->[2] - $a->[2]*$b->[1],
                $a->[2]*$b->[0] - $a->[0]*$b->[2],
                $a->[0]*$b->[1] - $a->[1]*$b->[0]
            ];


            if ($cross->[0] == $c->[0] &&
                $cross->[1] == $c->[1] &&
                $cross->[2] == $c->[2]) {

                push @rots, [$p,$s];
            }
        }
    }


    return @rots;
}



sub rotate_point {

    my ($p,$perm,$sign)=@_;

    return [
        $p->[$perm->[0]] * $sign->[0],
        $p->[$perm->[1]] * $sign->[1],
        $p->[$perm->[2]] * $sign->[2]
    ];
}



sub apply_rotation {

    my ($points,$rot)=@_;

    my ($perm,$sign)=@$rot;

    my @out;

    for my $p (@$points) {

        push @out,
            rotate_point($p,$perm,$sign);
    }

    return \@out;
}



# --------------------------------------------------
# Try aligning scanner B to scanner A
# --------------------------------------------------

sub align {

    my ($a,$b,$rots)=@_;


    for my $rot (@$rots) {

        my $rb = apply_rotation($b,$rot);


        my %offsets;


        for my $pa (@$a) {

            for my $pb (@$rb) {

                my $dx=$pa->[0]-$pb->[0];
                my $dy=$pa->[1]-$pb->[1];
                my $dz=$pa->[2]-$pb->[2];


                my $key="$dx,$dy,$dz";

                $offsets{$key}++;
            }
        }


        for my $key (keys %offsets) {

            next unless $offsets{$key} >= 12;


            my ($dx,$dy,$dz)=split /,/,$key;


            my @fixed;


            for my $p (@$rb) {

                push @fixed,
                [
                    $p->[0]+$dx,
                    $p->[1]+$dy,
                    $p->[2]+$dz
                ];
            }


            return (\@fixed, [$dx,$dy,$dz]);
        }
    }


    return (undef,undef);
}



# --------------------------------------------------
# Solve
# --------------------------------------------------

my @rots = rotations();


my %fixed;

$fixed{0} = [
    [0,0,0],
    $scanners[0]
];


my @queue=(0);


my %beacons;

for my $b (@{$scanners[0]}) {

    $beacons{
        join(",",@$b)
    }=1;
}


my %scanner_pos;

$scanner_pos{0}=[0,0,0];



while (@queue) {

    my $i=shift @queue;


    for my $j (0..$#scanners) {

        next if exists $fixed{$j};


        my ($aligned,$offset)=
            align($fixed{$i}[1],$scanners[$j],\@rots);


        if ($aligned) {


            $fixed{$j}=[$offset,$aligned];

            $scanner_pos{$j}=$offset;


            push @queue,$j;


            for my $b (@$aligned) {

                $beacons{
                    join(",",@$b)
                }=1;
            }
        }
    }
}



my $p1 = scalar keys %beacons;



my @positions = values %scanner_pos;

my $p2=0;


for my $a (@positions) {

    for my $b (@positions) {

        my $d =
            abs($a->[0]-$b->[0]) +
            abs($a->[1]-$b->[1]) +
            abs($a->[2]-$b->[2]);

        $p2=$d if $d>$p2;
    }
}



print "2021 day19: pl_ans_1: $p1\n";
print "2021 day19: pl_ans_2: $p2\n";

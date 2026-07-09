use strict;
use warnings;


my %NUM_PAD = (
    '7'=>[0,0], '8'=>[0,1], '9'=>[0,2],
    '4'=>[1,0], '5'=>[1,1], '6'=>[1,2],
    '1'=>[2,0], '2'=>[2,1], '3'=>[2,2],
    '0'=>[3,1], 'A'=>[3,2],
);


my %DIR_PAD = (
    '^'=>[0,1],
    'A'=>[0,2],
    '<'=>[1,0],
    'v'=>[1,1],
    '>'=>[1,2],
);


my %DIRS = (
    '^'=>[-1,0],
    'v'=>[1,0],
    '<'=>[0,-1],
    '>'=>[0,1],
);



sub bfs_paths {

    my ($start,$end,$pad)=@_;


    my ($sr,$sc)=@{$pad->{$start}};
    my ($tr,$tc)=@{$pad->{$end}};


    my @q=([$sr,$sc,""]);

    my $best;

    my @res;


    while (@q) {

        my ($r,$c,$path)=@{shift @q};


        next if defined($best) && length($path)>$best;


        if ($r==$tr && $c==$tc) {

            $best=length($path)
                unless defined $best;


            push @res,$path."A"
                if length($path)==$best;

            next;
        }


        for my $ch (keys %DIRS) {

            my ($dr,$dc)=@{$DIRS{$ch}};

            my ($nr,$nc)=($r+$dr,$c+$dc);


            my $ok=0;

            for my $v (values %$pad) {

                if ($nr==$v->[0] && $nc==$v->[1]) {
                    $ok=1;
                    last;
                }
            }


            push @q,[$nr,$nc,$path.$ch]
                if $ok;
        }
    }


    return \@res;
}



my %NUM_PATHS;
my %DIR_PATHS;


for my $a (keys %NUM_PAD) {

    for my $b (keys %NUM_PAD) {

        $NUM_PATHS{"$a,$b"}=
            bfs_paths($a,$b,\%NUM_PAD);
    }
}


for my $a (keys %DIR_PAD) {

    for my $b (keys %DIR_PAD) {

        $DIR_PATHS{"$a,$b"}=
            bfs_paths($a,$b,\%DIR_PAD);
    }
}



my %CACHE;


sub solve {

    my ($seq,$depth)=@_;


    my $cache="$seq|$depth";

    return $CACHE{$cache}
        if exists $CACHE{$cache};


    return length($seq)
        if $depth==0;


    my $total=0;

    my $cur="A";


    for my $ch (split //,$seq) {

        my $best=1e99;


        for my $path (@{
            $DIR_PATHS{"$cur,$ch"}
        }) {

            my $v=solve($path,$depth-1);

            $best=$v if $v<$best;
        }


        $total += $best;

        $cur=$ch;
    }


    $CACHE{$cache}=$total;

    return $total;
}



sub expand {

    my ($code,$depth)=@_;


    my $cur="A";

    my $total=0;


    for my $ch (split //,$code) {

        my $best=1e99;


        for my $path (@{
            $NUM_PATHS{"$cur,$ch"}
        }) {

            my $v=solve($path,$depth);

            $best=$v if $v<$best;
        }


        $total += $best;

        $cur=$ch;
    }


    return $total;
}



sub run {

    my ($lines,$depth)=@_;


    my $ans=0;


    for my $line (@$lines) {

        my $val=substr($line,0,-1);

        my $cost=expand($line,$depth);


        $ans += $cost * $val;
    }


    return $ans;
}



my $path=$ARGV[0];

open my $fh,'<',$path or die "$path: $!";

my @lines=<$fh>;

close $fh;


chomp @lines;

@lines=grep { /\S/ } @lines;


my $p1=run(\@lines,2);

my $p2=run(\@lines,25);


print "2024 day21: pl_ans_1: $p1\n";
print "2024 day21: pl_ans_2: $p2\n";

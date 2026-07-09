use strict;
use warnings;


my $DAY=23;



# ---------------- PARSE ----------------

sub parse {

    my ($data)=@_;


    my %g;


    for my $line (split /\n/,$data) {

        next unless $line =~ /\S/;


        my ($a,$b)=split /-/,$line;


        $g{$a}{$b}=1;
        $g{$b}{$a}=1;
    }


    return \%g;
}



# helper: hash keys as set

sub keys_set {

    my ($h)=@_;

    return { map { $_=>1 } keys %$h };
}



# ---------------- PART 1 TRIANGLES ----------------

sub part1 {

    my ($g)=@_;


    my @nodes=keys %$g;

    my $count=0;


    for my $a (@nodes) {

        for my $b (keys %{$g->{$a}}) {

            next if $b le $a;


            for my $c (keys %{$g->{$b}}) {

                next if $c le $b;


                if (exists $g->{$c}{$a}) {

                    if (
                        substr($a,0,1) eq "t" ||
                        substr($b,0,1) eq "t" ||
                        substr($c,0,1) eq "t"
                    ) {
                        $count++;
                    }
                }
            }
        }
    }


    return $count;
}



# ---------------- SET INTERSECTION ----------------

sub intersect {

    my ($a,$b)=@_;

    my %out;


    for my $k (keys %$a) {

        $out{$k}=1
            if exists $b->{$k};
    }


    return \%out;
}



# ---------------- BRON-KERBOSCH ----------------

sub bronk {

    my ($R,$P,$X,$g,$best)=@_;


    if (!keys %$P && !keys %$X) {

        if (scalar(keys %$R) >
            scalar(keys %{$best->[0]})) {

            $best->[0]={%$R};
        }

        return;
    }


    for my $v (keys %$P) {


        my %newR=%$R;
        $newR{$v}=1;


        my $newP=intersect(
            $P,
            $g->{$v} // {}
        );


        my $newX=intersect(
            $X,
            $g->{$v} // {}
        );


        bronk(
            \%newR,
            $newP,
            $newX,
            $g,
            $best
        );


        delete $P->{$v};
        $X->{$v}=1;
    }
}



# ---------------- PART 2 ----------------

sub part2 {

    my ($g)=@_;


    my %P=map { $_=>1 } keys %$g;


    my $best=[{}];


    bronk(
        {},
        \%P,
        {},
        $g,
        $best
    );


    return join(",",
        sort keys %{$best->[0]}
    );
}



# ---------------- MAIN ----------------

my $path=$ARGV[0];


open my $fh,'<',$path or die "$path: $!";

local $/;

my $data=<$fh>;

close $fh;


my $g=parse($data);


my $ans1=part1($g);
my $ans2=part2($g);


print "2024 day$DAY: pl_ans_1: $ans1\n";
print "2024 day$DAY: pl_ans_2: $ans2\n";

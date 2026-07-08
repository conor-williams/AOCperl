use strict;
use warnings;


sub contains_all {
    my ($a, $b) = @_;

    for my $x (keys %$b) {
        return 0 unless exists $a->{$x};
    }

    return 1;
}


sub set_from_string {

    my ($s) = @_;

    my %h;

    for my $c (split //, $s) {
        $h{$c} = 1;
    }

    return \%h;
}


sub sorted_key {

    my ($s) = @_;

    return join("", sort split //, $s);
}


sub decode {

    my ($patterns) = @_;

    my @sets = map { set_from_string($_) } @$patterns;

    my %nums;


    for my $s (@sets) {
        my $len = scalar(keys %$s);

        $nums{1} = $s if $len == 2;
        $nums{4} = $s if $len == 4;
        $nums{7} = $s if $len == 3;
        $nums{8} = $s if $len == 7;
    }


    my @sixes = grep {
        scalar(keys %$_) == 6
    } @sets;


    for my $s (@sixes) {
        if (contains_all($s, $nums{4})) {
            $nums{9} = $s;
        }
    }


    @sixes = grep {
        $_ != $nums{9}
    } @sixes;


    for my $s (@sixes) {
        if (contains_all($s, $nums{1})) {
            $nums{0} = $s;
        }
    }


    @sixes = grep {
        $_ != $nums{0}
    } @sixes;

    $nums{6} = $sixes[0];


    my @fives = grep {
        scalar(keys %$_) == 5
    } @sets;


    for my $s (@fives) {
        if (contains_all($s, $nums{1})) {
            $nums{3} = $s;
        }
    }


    @fives = grep {
        $_ != $nums{3}
    } @fives;


    for my $s (@fives) {
        if (contains_all($nums{6}, $s)) {
            $nums{5} = $s;
        }
    }


    @fives = grep {
        $_ != $nums{5}
    } @fives;


    $nums{2} = $fives[0];


    my %rev;

    for my $n (keys %nums) {

        my $key = join("", sort keys %{$nums{$n}});

        $rev{$key} = $n;
    }

    return \%rev;
}



my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @lines = <$fh>;

close $fh;


my $p1 = 0;
my $p2 = 0;


for my $line (@lines) {

    chomp $line;

    next unless $line =~ /\S/;


    my ($left, $right) = split / \| /, $line;


    my @patterns = split / /, $left;
    my @output   = split / /, $right;


    for my $x (@output) {
        my $l = length($x);
        $p1++ if $l == 2 || $l == 3 || $l == 4 || $l == 7;
    }


    my $table = decode(\@patterns);


    my $value = "";

    for my $x (@output) {

        my $k = join("", sort split //, $x);

        $value .= $table->{$k};
    }


    $p2 += int($value);
}


print "2021 day8: pl_ans_1: $p1\n";
print "2021 day8: pl_ans_2: $p2\n";

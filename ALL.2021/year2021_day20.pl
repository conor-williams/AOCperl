use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";
my $text = do { local $/; <$fh> };
close $fh;


sub parse {

    my ($text)=@_;

    my ($algo,$image)=split /\n\n/, $text;

    $algo =~ s/\s+//g;

    my @grid;

    for my $line (split /\n/,$image) {
        push @grid,[split //,$line];
    }

    return ($algo,\@grid);
}



sub pad {

    my ($grid,$amount,$fill)=@_;

    my $h=@$grid;
    my $w=@{$grid->[0]};


    my @new;

    for my $y (0..$h+$amount*2-1) {

        my @row;

        for my $x (0..$w+$amount*2-1) {
            push @row,$fill;
        }

        push @new,\@row;
    }


    for my $y (0..$h-1) {

        for my $x (0..$w-1) {

            $new[$y+$amount][$x+$amount]
                =
            $grid->[$y][$x];
        }
    }


    return \@new;
}



sub step {

    my ($grid,$algo,$default)=@_;

    my $h=@$grid;
    my $w=@{$grid->[0]};


    my @new;

    for my $y (0..$h-1) {

        my @row;

        for my $x (0..$w-1) {

            my $bits=0;


            for my $dy (-1,0,1) {

                for my $dx (-1,0,1) {

                    $bits <<= 1;


                    my $nx=$x+$dx;
                    my $ny=$y+$dy;


                    if ($nx>=0 &&
                        $nx<$w &&
                        $ny>=0 &&
                        $ny<$h) {

                        $bits |= 1
                            if $grid->[$ny][$nx] eq "#";
                    }
                    else {

                        $bits |= 1
                            if $default eq "#";
                    }
                }
            }


            push @row,substr($algo,$bits,1);
        }

        push @new,\@row;
    }


    my $new_default;

    if ($default eq ".") {
        $new_default=substr($algo,0,1);
    }
    else {
        $new_default=substr($algo,511,1);
    }


    return (\@new,$new_default);
}



sub count_hash {

    my ($grid)=@_;

    my $count=0;

    for my $row (@$grid) {

        for my $c (@$row) {
            $count++ if $c eq "#";
        }
    }

    return $count;
}



my ($algo,$grid)=parse($text);


$grid=pad($grid,60,".");

my $default=".";

my $p1;


for my $i (0..49) {

    ($grid,$default)=step($grid,$algo,$default);

    if ($i==1) {
        $p1=count_hash($grid);
    }
}


my $p2=count_hash($grid);


print "2021 day20: pl_ans_1: $p1\n";
print "2021 day20: pl_ans_2: $p2\n";

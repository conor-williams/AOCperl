use strict;
use warnings;


sub rotate {
    my ($grid) = @_;

    my $n = scalar(@$grid);
    my @out;

    for my $x (0 .. $n-1) {
        my @row;

        for (my $y = $n-1; $y >= 0; $y--) {
            push @row, $grid->[$y]->[$x];
        }

        push @out, \@row;
    }

    return \@out;
}


sub flip {
    my ($grid) = @_;

    my @out;

    for my $row (@$grid) {
        push @out, [ reverse @$row ];
    }

    return \@out;
}


sub key {
    my ($g) = @_;

    return join("/", map { join("", @$_) } @$g);
}


sub variants {
    my ($grid) = @_;

    my %seen;
    my @result;

    my $g = $grid;

    for (1..4) {

        my $k = key($g);
        unless (exists $seen{$k}) {
            $seen{$k}=1;
            push @result, $g;
        }

        my $fg = flip($g);

        $k = key($fg);
        unless (exists $seen{$k}) {
            $seen{$k}=1;
            push @result, $fg;
        }

        $g = rotate($g);
    }

    return @result;
}


sub parse_rules {
    my (@lines)= @_;

    my %rules;

    for my $line (@lines) {
        my ($left,$right)=split(/ => /,$line);

        my @l = map { [split //] } split(/\//,$left);
        my @r = map { [split //] } split(/\//,$right);

        for my $v (variants(\@l)) {
            $rules{key($v)}=\@r;
        }
    }

    return \%rules;
}


sub split_grid {
    my ($grid,$size)=@_;

    my $n=scalar(@$grid);
    my @blocks;

    for(my $y=0;$y<$n;$y+=$size) {
        for(my $x=0;$x<$n;$x+=$size) {

            my @block;

            for my $i (0..$size-1) {
                push @block, [
                    @{$grid->[$y+$i]}[$x..$x+$size-1]
                ];
            }

            push @blocks,\@block;
        }
    }

    return @blocks;
}


sub combine {
    my (@blocks)=@_;

    my $block_size=scalar(@{$blocks[0]});
    my $count=sqrt(scalar(@blocks));

    my $size=$block_size*$count;

    my @grid=map { [ ("") x $size ] } 1..$size;

    my $i=0;

    for my $by (0..$count-1) {
        for my $bx (0..$count-1) {

            my $block=$blocks[$i++];

            for my $y (0..$block_size-1) {
                for my $x (0..$block_size-1) {
                    $grid[$by*$block_size+$y]
                         [$bx*$block_size+$x]
                         =$block->[$y]->[$x];
                }
            }
        }
    }

    return \@grid;
}


sub enhance {
    my ($grid,$rules)=@_;

    my $n=scalar(@$grid);

    my $size=($n % 2 == 0) ? 2 : 3;

    my @blocks=split_grid($grid,$size);

    my @new;

    for my $b (@blocks) {
        push @new,$rules->{key($b)};
    }

    return combine(@new);
}


sub run {
    my ($iterations,$rules)=@_;

    my $grid=[
        [".","#","."],
        [".",".","#"],
        ["#","#","#"]
    ];

    for (1..$iterations) {
        $grid=enhance($grid,$rules);
    }

    my $count=0;

    for my $row (@$grid) {
        for my $c (@$row) {
            $count++ if $c eq "#";
        }
    }

    return $count;
}


sub main {

    open(my $fh,"<",$ARGV[0]) or die $!;

    my @lines=<$fh>;
    chomp @lines;

    my $rules=parse_rules(@lines);

    print "2017 day21: pl_ans_1: ", run(5,$rules), "\n";
    print "2017 day21: pl_ans_2: ", run(18,$rules), "\n";
}

main();

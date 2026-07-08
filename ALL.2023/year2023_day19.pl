#!/usr/bin/perl
use strict;
use warnings;

sub parse {
    my ($text)=@_;

    my ($wf_text,$parts_text)=split /\n\n/, $text;

    my %W;

    for my $line (split /\n/, $wf_text) {

        my ($name,$rest)=split /\{/, $line;

        $rest =~ s/\}//;

        my @rules;

        for my $r (split /,/, $rest) {

            if ($r =~ /:/) {
                my ($cond,$dest)=split /:/,$r;
                push @rules, [$cond,$dest];
            }
            else {
                push @rules, [undef,$r];
            }
        }

        $W{$name}=\@rules;
    }

    my @P;

    for my $line (split /\n/, $parts_text) {
        my @nums=$line =~ /(\d+)/g;
        push @P, \@nums;
    }

    return (\%W,\@P);
}

sub check {
    my ($cond,$x,$m,$a,$s)=@_;

    my ($var,$op,$val)=
        $cond =~ /([xmas])([<>])(\d+)/;

    my $v =
        $var eq "x" ? $x :
        $var eq "m" ? $m :
        $var eq "a" ? $a :
        $s;

    return $op eq "<" ? $v < $val : $v > $val;
}

sub part1 {
    my ($W,$parts)=@_;

    my $total=0;

    for my $p (@$parts) {

        my ($x,$m,$a,$s)=@$p;

        my $cur="in";

        while ($cur ne "A" && $cur ne "R") {

            for my $rule (@{ $W->{$cur} }) {

                my ($cond,$dest)=@$rule;

                if (!defined($cond) ||
                    check($cond,$x,$m,$a,$s)) {

                    $cur=$dest;
                    last;
                }
            }
        }

        if ($cur eq "A") {
            $total += $x+$m+$a+$s;
        }
    }

    return $total;
}

sub part2 {
    my ($W)=@_;

    my $dfs;

    $dfs = sub {
        my ($node,$xr,$mr,$ar,$sr)=@_;

        if ($node eq "R") {
            return 0;
        }

        if ($node eq "A") {
            return
                ($xr->[1]-$xr->[0]+1) *
                ($mr->[1]-$mr->[0]+1) *
                ($ar->[1]-$ar->[0]+1) *
                ($sr->[1]-$sr->[0]+1);
        }

        my $total=0;

        for my $rule (@{ $W->{$node} }) {

            my ($cond,$dest)=@$rule;

            if (!defined $cond) {
                $total += $dfs->($dest,$xr,$mr,$ar,$sr);
                last;
            }

            my ($var,$op,$val)=
                $cond =~ /([xmas])([<>])(\d+)/;

            my ($yes,$no);

            my $split=sub {
                my ($r)=@_;

                my ($lo,$hi)=@$r;

                if ($op eq "<") {
                    return (
                        [$lo, $hi < $val-1 ? $hi : $val-1],
                        [$lo > $val ? $lo : $val, $hi]
                    );
                }
                else {
                    return (
                        [$lo > $val+1 ? $lo : $val+1, $hi],
                        [$lo, $hi < $val ? $hi : $val]
                    );
                }
            };

            if ($var eq "x") {
                ($yes,$no)=$split->($xr);

                $total += $dfs->($dest,$yes,$mr,$ar,$sr)
                    if $yes->[0] <= $yes->[1];

                $xr=$no;
            }
            elsif ($var eq "m") {
                ($yes,$no)=$split->($mr);

                $total += $dfs->($dest,$xr,$yes,$ar,$sr)
                    if $yes->[0] <= $yes->[1];

                $mr=$no;
            }
            elsif ($var eq "a") {
                ($yes,$no)=$split->($ar);

                $total += $dfs->($dest,$xr,$mr,$yes,$sr)
                    if $yes->[0] <= $yes->[1];

                $ar=$no;
            }
            else {
                ($yes,$no)=$split->($sr);

                $total += $dfs->($dest,$xr,$mr,$ar,$yes)
                    if $yes->[0] <= $yes->[1];

                $sr=$no;
            }
        }

        return $total;
    };

    return $dfs->(
        "in",
        [1,4000],
        [1,4000],
        [1,4000],
        [1,4000]
    );
}

sub main {
    my $path=$ARGV[0];

    open my $fh,"<",$path or die "$path: $!";

    local $/;
    my $text=<$fh>;

    close $fh;

    my ($W,$P)=parse($text);

    my $p1=part1($W,$P);
    my $p2=part2($W);

    print "2023 day19: pl_ans_1: $p1\n";
    print "2023 day19: pl_ans_2: $p2\n";
}

main();

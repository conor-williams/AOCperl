use strict;
use warnings;


sub checksum {
    my ($blocks) = @_;

    my $sum = 0;

    for my $i (0 .. $#$blocks) {
        $sum += $i * $blocks->[$i]
            if defined $blocks->[$i];
    }

    return $sum;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

local $/;
my $s = <$fh>;

close $fh;

$s =~ s/\s+//g;

my @nums = map { int($_) } split //, $s;


# ---------------- Part 1 ----------------

my @blocks;
my $file_id = 0;

for my $i (0 .. $#nums) {

    my $n = $nums[$i];

    if ($i % 2 == 0) {

        push @blocks, ($file_id) x $n;
        $file_id++;

    }
    else {

        push @blocks, (undef) x $n;
    }
}


my ($l, $r) = (0, $#blocks);

while ($l < $r) {

    while ($l < $r && defined $blocks[$l]) {
        $l++;
    }

    while ($l < $r && !defined $blocks[$r]) {
        $r--;
    }

    if ($l < $r) {

        $blocks[$l] = $blocks[$r];
        $blocks[$r] = undef;
    }
}


my $p1 = checksum(\@blocks);


# ---------------- Part 2 ----------------

my @files;
my @spaces;

my $pos = 0;
$file_id = 0;


for my $i (0 .. $#nums) {

    my $n = $nums[$i];

    if ($i % 2 == 0) {

        # start, size, id
        push @files, [$pos, $n, $file_id];

        $file_id++;

    }
    else {

        if ($n > 0) {
            push @spaces, [$pos, $n];
        }
    }

    $pos += $n;
}


# move files right-to-left

for (my $i = $#files; $i >= 0; $i--) {

    my ($fpos, $fsize, $fid) = @{$files[$i]};

    for my $s (@spaces) {

        my ($spos, $ssize) = @$s;

        last if $spos >= $fpos;

        if ($ssize >= $fsize) {

            # move file
            $files[$i]->[0] = $spos;

            # consume space
            $s->[0] += $fsize;
            $s->[1] -= $fsize;

            last;
        }
    }
}


# rebuild final disk

my $max_pos = 0;

for my $f (@files) {

    my ($p, $size, $id) = @$f;

    my $end = $p + $size;

    $max_pos = $end if $end > $max_pos;
}


my @disk = (undef) x $max_pos;


for my $f (@files) {

    my ($p, $size, $id) = @$f;

    for my $i (0 .. $size - 1) {
        $disk[$p + $i] = $id;
    }
}


my $p2 = checksum(\@disk);


print "2024 day9: pl_ans_1: $p1\n";
print "2024 day9: pl_ans_2: $p2\n";

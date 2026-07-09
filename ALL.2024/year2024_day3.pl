use strict;
use warnings;

my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";
local $/;
my $data = <$fh>;
close $fh;

# Part 1
my $p1 = 0;

while ($data =~ /mul\((\d{1,3}),(\d{1,3})\)/g) {
    $p1 += $1 * $2;
}

# Part 2
my $p2 = 0;
my $enabled = 1;

while ($data =~ /mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/g) {

    my $s = $&;

    if ($s eq "do()") {
        $enabled = 1;
    }
    elsif ($s eq "don't()") {
        $enabled = 0;
    }
    else {
        if ($enabled) {
            $p2 += $1 * $2;
        }
    }
}

print "2024 day3: pl_ans_1: $p1\n";
print "2024 day3: pl_ans_2: $p2\n";

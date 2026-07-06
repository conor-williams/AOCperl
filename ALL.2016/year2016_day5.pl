use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my $door_id = <$fh>;
chomp $door_id;

# --------------------
# Part 1
# --------------------
my $password1 = "";
my $i = 0;

while (length($password1) < 8) {
    my $h = md5_hex($door_id . $i);

    if (substr($h, 0, 5) eq "00000") {
        $password1 .= substr($h, 5, 1);
    }

    $i++;
}

# --------------------
# Part 2
# --------------------
my @password2 = ("_") x 8;
my $filled = 0;
$i = 0;

while ($filled < 8) {
    my $h = md5_hex($door_id . $i);

    if (substr($h, 0, 5) eq "00000") {
        my $pos = substr($h, 5, 1);

        if ($pos =~ /^\d$/) {
            $pos += 0;

            if ($pos >= 0 && $pos < 8 && $password2[$pos] eq "_") {
                $password2[$pos] = substr($h, 6, 1);
                $filled++;
            }
        }
    }

    $i++;
}

print "2016 day5: pl_ans_1: $password1\n";
print "2016 day5: pl_ans_2: ", join("", @password2), "\n";

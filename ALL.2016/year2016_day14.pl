use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

# -------------------------
# part 1 hash
# -------------------------
sub hash1 {
    my ($salt, $i) = @_;
    return md5_hex($salt . $i);
}

# -------------------------
# part 2 hash (2016 extra hashes)
# -------------------------
sub hash2 {
    my ($salt, $i) = @_;
    my $h = hash1($salt, $i);

    for (1..2016) {
        $h = md5_hex($h);
    }

    return $h;
}

# -------------------------
# find 5x repeat in future window
# -------------------------
sub has_quint {
    my ($hashes, $ch) = @_;
    my $target = $ch x 5;

    for my $h (@$hashes) {
        return 1 if index($h, $target) != -1;
    }

    return 0;
}

# -------------------------
# core solver (same logic as Python)
# -------------------------
sub solve {
    my ($salt, $hash_fn) = @_;

    my $re = qr/(.)\1\1/;

    my @hashes;

    # initial window
    for my $i (0..1000) {
        push @hashes, $hash_fn->($salt, $i);
    }

    my $index = 0;
    my $found = 0;

    while (1) {

        my $h = shift @hashes;

        if ($h =~ $re) {
            my $ch = $1;

            if (has_quint(\@hashes, $ch)) {
                $found++;
                last if $found >= 64;
            }
        }

        push @hashes, $hash_fn->($salt, $index + 1001);
        $index++;
    }

    return $index;
}

# -------------------------
# main
# -------------------------
open my $fh, "<", $ARGV[0] or die $!;
my $salt = <$fh>;
chomp $salt;

my $p1 = solve($salt, \&hash1);
my $p2 = solve($salt, \&hash2);

print "2016 day14: pl_ans_1: $p1\n";
print "2016 day14: pl_ans_2: $p2\n";

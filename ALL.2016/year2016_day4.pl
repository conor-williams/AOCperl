use strict;
use warnings;

sub parse {
    my ($line) = @_;
    if ($line =~ /([a-z\-]+)-(\d+)\[([a-z]+)\]/) {
        return ($1, $2, $3);
    }
    return;
}

sub is_real {
    my ($name, $checksum) = @_;

    $name =~ s/-//g;

    my %count;
    $count{$_}++ for split //, $name;

    my @sorted = sort {
        $count{$b} <=> $count{$a}
        ||
        $a cmp $b
    } keys %count;

    my $calc = join "", @sorted[0..4];
    return $calc eq $checksum;
}

sub decrypt {
    my ($name, $sector) = @_;
    my $res = "";

    for my $ch (split //, $name) {
        if ($ch eq "-") {
            $res .= " ";
        } else {
            my $ord = ord($ch) - 97;
            $ord = ($ord + $sector) % 26;
            $res .= chr($ord + 97);
        }
    }

    return $res;
}

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my $total = 0;
my $northpole_sector;

while (my $line = <$fh>) {
    chomp $line;

    my ($name, $sector, $checksum) = parse($line);

    next unless defined $name;

    if (is_real($name, $checksum)) {
        $total += $sector;

        my $decrypted = decrypt($name, $sector);
        if ($decrypted =~ /northpole object storage/) {
            $northpole_sector = $sector;
        }
    }
}

print "2016 day4: pl_ans_1: $total\n";
print "2016 day4: pl_ans_2: $northpole_sector\n";

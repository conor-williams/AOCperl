use strict;
use warnings;

my $code = 0;
my $mem  = 0;
my $enc  = 0;

while (<>) {
    chomp;

    $code += length($_);

    my $s = $_;

    # strip quotes
    $s =~ s/^"//;
    $s =~ s/"$//;

    # decode step-by-step correctly
    my $i = 0;
    my $out = "";

    while ($i < length($s)) {
        my $c = substr($s, $i, 1);

        if ($c eq '\\') {
            my $n = substr($s, $i+1, 1);

            if ($n eq '\\' || $n eq '"') {
                $out .= $n;
                $i += 2;
            }
            elsif ($n eq 'x') {
                $out .= '_';   # placeholder char
                $i += 4;
            }
        }
        else {
            $out .= $c;
            $i++;
        }
    }

    $mem += length($out);

    # encoding (correct)
    my $e = $_;
    $e =~ s/\\/\\\\/g;
    $e =~ s/"/\\"/g;
    $e = '"' . $e . '"';

    $enc += length($e);
}

print "2015 day8: pl_ans_1: " . ($code - $mem) . "\n";
print "2015 day8: pl_ans_2: " . ($enc - $code) . "\n";

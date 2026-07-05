#!/usr/bin/env perl
use strict;
use warnings;

sub extract_day {
    my ($f) = @_;
    return $1 if $f =~ /day(\d+)/;
    return 999999;
}

opendir(my $dh, ".") or die $!;

my @dirs = sort grep { /^ALL\./ && -d $_ } readdir($dh);

closedir($dh);

for my $dirname (@dirs) {

    print "\t\t=== Directory: $dirname ===\n";

    opendir(my $dh2, $dirname) or next;

    my @plfiles = grep { /^year.*\.pl$/ } readdir($dh2);

    closedir($dh2);

    @plfiles = sort { extract_day($a) <=> extract_day($b) } @plfiles;

    for my $plfile (@plfiles) {

        (my $base = $plfile) =~ s/\.pl$//;
        my $infile = "$base.i1.txt";

        # ✅ FIX: no ALL.2015 prefix
        my $full_in = $infile;

        unless (-e "$dirname/$full_in") {
            print "Skipping $plfile (missing $infile)\n";
            next;
        }

        system("cd $dirname && perl $plfile $full_in") == 0
            or print "FAILED: $plfile\n";
    }
}

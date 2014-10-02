#!/usr/bin/perl
#requires perl-IO-Compress-Base.x86_64
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;

# from seqanswers.com
# http://seqanswers.com/forums/showthread.php?t=1801
# by Xi Wang

use warnings;
use strict;


my $z = new IO::Uncompress::Gunzip $ARGV[0]  
                or die "gunzip failed: $GunzipError\n";
        
while (<$z>) {
        chomp;
        my @parts = split /\t/;
        print "@","$parts[0]:$parts[2]:$parts[3]:$parts[4]:$parts[5]#$parts[6]/$parts[7]\n";
        print "$parts[8]\n";
        print "+\n";
        print "$parts[9]\n";
}

close $z ;

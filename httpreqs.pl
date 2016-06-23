#!/usr/bin/perl

use strict;
use AnyEvent;
use AnyEvent::HTTP;
use Time::HiRes qw/gettimeofday/;
#use Data::Dumper::Simple;

my @URLs;
while ( <> ){
    my $input = $_;
    chomp( $input );
    if ( $input =~ m{^(https?|ftp)://[^\s/$.?#].[^\s]*$} ){
            push @URLs, $input;
    }
}

if ( 0 == scalar @URLs ){
    print "no urls defined, exit\n";
    exit;
}

my $cv = AnyEvent->condvar;

my $req_num = 0;
foreach my $URL (@URLs){
    print "Start GET $URL\n";
    $cv->begin;
    my $start_time = gettimeofday();
    http_get $URL, sub {
        my ($html) = @_;
        my $end_time = gettimeofday();
        my $interval = sprintf("%.3f", $end_time-$start_time );
        print "GOT $URL, Size: ", length (defined $html)? length $html: 0," bytes in ", $interval , " secs\n";
        $cv->end;
    };
}

$cv->recv;


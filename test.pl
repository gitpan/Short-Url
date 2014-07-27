#!/usr/bin/perl
use strict;
use lib 'lib';
use Short::URL;

my $su = Short::URL->new(offset => 10000, use_shuffled_alphabet => 1);
#my $su = Short::URL->new;

my $short_url = $su->encode($ARGV[0]);

print "SHORTENED: $short_url\n";

my $decoded = $su->decode($short_url);
print "DECODED: $decoded\n";

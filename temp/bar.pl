#!/usr/bin/env perl

use Foo;

Foo->one;

my %goo = (
	'key1' => 1,
	'key' => 2	
);

$object = new Foo("Greg", 28, \%goo);
my $check = 0;
print "check baby\n" unless $check == 1;

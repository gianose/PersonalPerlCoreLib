#!/usr/bin/env perl

use Exception;
use Switch;
use Data::Dumper;

#my %foo = (
#	FooBar => 64
#);
#Exception->new( \@foo );
#Exception->new( \@foo, $bar );
#$object->throw('foo','bar');
#throw('InvalidArgument', 'This a test');
#throw('foo','bar');
#sub x {
#	$object->throw('FooBar', 'This a test');
#}

#sub foo { x; }
sub bar {
	print $_[0] . " " . $_[1] . "\n";	
	print "This is a test\n";
}
#bar;

my @ERROR = (
	{
		function => sub { Exception->new(@_); },
		message  => 'Exception::new - Attempt to call new with more than one parameter',
		expect   => 113,
		params   => [ 'foo', 'bar' ],
	}
);

#$ERROR[0]{function}(join(",", $ERROR[0]{params}));


#print "Error captured : $@\n";
#print "testing " . $ERROR[0]{message} . "\n";
#print "testing " . $ERROR[0]{expect} . "\n";
#print "testing " . $ERROR[0]{params}[1]. "\n";

sub UnitTest {
	sub unitTest(@) {
		my $unit = shift;

		foreach ($unit) {
			switch(scalar @{ $_->{params} }) {
				case 0 {
					try {
						$_->{function}();
					} catch {
						/$_->{expect}/ && print "Hello There " . $_->{expect} . "\n";
					}
				}
				case 1 {
					try {
						$_->{function}($_->{params}[0]);
					} catch {
						/$_->{expect}/ && print "Hello There " . $_->{expect} . "\n";
					}
				}
				case 2 {
					try {
						$_->{function}($_->{params}[0], $_->{params}[1]);
					} catch {
						/$_->{expect}/ && print "Hello There " . $_->{expect} . "\n";
					}
				}
			}
		}
	}

	return 1;
}

UnitTest;
unitTest(@ERROR);

#!/usr/bin/env perl
package Foo;

# Use modules not in same directory
# use lib qw()

use strict;
use warnings;

use constant FAULT => 'Cheese';

sub Foo(){
	sub new {
		my $class = shift;
		print "Tell me ref " . ref($_[2]) . "\n";
		my $self = {
			name => shift,
			age  => shift,
			hash => shift
		};
		print "Name is $self->{name}\n";
		print "Age is $self->{age}\n";
		print "hash is a " . $self->{hash}->{'key1'} . "\n" if ($self->{hash});
		print "Let see " . ref($self->{hash}) . "\n";
		print "Testing " . FAULT . "\n";
		print "Array test " . $self->{array}[0] . "\n";
		push $self->{array}, 'burger';
		print "Array test " . $self->{array}[0] . "\n";
		push $self->{array}, 'cheese';
		print "Array test " . $self->{array}[1] . "\n";
		print "Array test " . $self->{array}[0] . "\n";
		print "Array test " . scalar @{ $self->{array} }. "\n";
		bless $self, $class;
		return $self;
	}

	sub one {
		my $self = shift;
		print "Testing one two three\n";
		return 1;
	}

	return 1;
}

Foo;



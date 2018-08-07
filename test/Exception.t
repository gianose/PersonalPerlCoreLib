#!/usr/bin/env perl

# @name: Exception.t
# @process: Exception
# @author: Gregory Rose
# @created: 20180803
# @modified: 20180807
# @version: 0.01

# @constant: string: NAMESPACE: The persent working directory of the this class.
use constant NAMESPACE => $ENV{PWD} =~ s/\/\w+$//r;

use lib NAMESPACE . '/lib/core';
use strict;
use warnings;
use Exception;
use UnitTest;

my %EXCEPTION_ALREADY_EXISTS = ( 'ArgumentCountError' => 103 );
my %EXCEPTION_UPPER_BOUND = ( 'CheeseBurger' => 91 );
my %EXCEPTION_LOWER_BOUND = ( 'FrenchFries' => 63 );

my @EXCEPTION_ERROR = (
	{
		message  => "Exception::new - Attempt to call Exception::new with more than one parameter",
		function => sub { my $object = new Exception(@_); },
		expect   => 103,
		params   => [ 'foo', 'bar' ]	
	},
	{
		message  => "Exception::new - Attempt to call Exception::new with non hash parameter",
		function => sub { my $object = new Exception(@_); },
		expect   => 101,
		params   => [ 'foo' ]	
	},
	{
		message  => "Exception::new - Attempt to call Exception::new with an exception that already exists",
		function => sub { my $object = new Exception(@_); },
		expect   => 113,
		params   => [ \%EXCEPTION_ALREADY_EXISTS ]	
	},
	{
		message  => "Exception::new - Attempt to call Exception::new with a exceptions who's corresponding exit code is not within range, upper bound",
		function => sub { my $object = new Exception(@_); },
		expect   => 102,
		params   => [ \%EXCEPTION_UPPER_BOUND ]	
	},
	{
		message  => "Exception::new - Attempt to call Exception::new with a exceptions who's corresponding exit code is not within range, lower bound",
		function => sub { my $object = new Exception(@_); },
		expect   => 102,
		params   => [ \%EXCEPTION_LOWER_BOUND ]	
	},
	{
		message  => "Exception::incite - Attempt to call Exception::incite with zero parameters",
		function => \&incite,
		expect   => 103,
		params   => []
	},
	{
		function => \&incite,
		message  => "Exception::incite - Attempt to call Exception::incite with one parameter",
		expect   => 103,
		params   => [ 'InvalidArgument' ]
	},
	{
		function => \&incite,
		message  => "Exception::incite - Attempt to call Exception::incite with four parameter",
		expect   => 103,
		params   => [ 'InvalidArgument', 'foo', 'bar', 'bam' ]
	},
	{
		function => \&incite,
		message  => "Exception::incite - Attempt to call Exception::incite with an unregistered exception",
		expect   => 102,
		params   => [ 'CheeseBurger', '113' ]
	},
	{
		function => \&throw,
		message  => "Exception::throw - Attempt to call Exception::throw with zero parameters",
		expect   => 103,
		params   => []
	},
	{
		function => \&throw,
		message  => "Exception::throw - Attempt to call Exception::throw with one parameter",
		expect   => 103,
		params   => [ 'InvalidArgument' ]
	},
	{
		function => \&throw,
		message  => "Exception::throw - Attempt to call Exception::throw with four parameters",
		expect   => 103,
		params   => [ 'InvalidArgument', 'This is a test', 'foo', 'bar' ]
	},
	{
		function => \&throw,
		message  => "Exception::throw - Attempt to call Exception::throw with a third parameter that is not a subroutine",
		expect   => 101,
		params   => [ 'InvalidArgument', 'This is a test', 'foo' ]
	},
);

my %EXCEPTION_GOOD = ( 'HyperBeam' => 64 );
my @EXCEPTION_USAGE = (
	{
		function => sub { my $object = new Exception(@_) && exit 0; },
		message  => "Exception::new - Successfully create an instance of Exception with a custom exception and valid corresponding exit code",
		expect   => 0,
		params   => [ \%EXCEPTION_GOOD ]
	},
	{
		function => sub { 
			my $obj = new Exception(@_); 
			$obj->throw( "HyperBeam", "I am having a blast" ); 
		},
		message  => "Exception::new - Successfully create and utilize an instance Exception",
		expect   => 64,
		params   => [ \%EXCEPTION_GOOD ]
	},
	{
		function => sub { incite("InvalidArgument", "This is a test") && exit 0; },
		message  => "Exception::incite - Successfully call incite with valid exception and a message",
		expect   => 0,
		params   => []
	},
	{
		function => sub { incite("InvalidArgument", "This is a test"); throw; },
		message  => "Exception::incite - Successfully incite then throw an exception",
		expect   => 113,
		params   => []
	},
	{
		function => sub { Exception::incite("InvalidArgument", "This is a test", sub { print "This happened before exit\n"; exit 65; }); Exception::throw; },
		message  => "Exception::incite - Successfully incite an exception with a task to execute before exit",
		expect   => 65,
		params   => []
	},
	{
		function => \&throw,
		message  => "Exception::thow - Successfully call throw with valid exception and message",
		expect   => 113,
		params   => ["InvalidArgument", "This is a test"]
	},
	{
		function => \&throw,
		message  => "Exception::thow - Successfully call throw with valid exception, message, and task to execute before exit",
		expect   => 66,
		params   => ["InvalidArgument", "This is a test", sub { print "This happened before exit\n"; exit 66; } ]
	}
);

print "ERRORS\n";
unitTest( \@EXCEPTION_ERROR );

print "USAGES\n";
unitTest( \@EXCEPTION_USAGE );

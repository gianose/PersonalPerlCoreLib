#!/usr/bin/env perl

# @name: Exception.pm
# @class: Exception
# @author: Gregory Rose
# @created: 20180725
# @modified: 20180726
# @version: 0.02

package Exception;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(incite throw);
@EXPORT = qw(@stack);

use strict;
use warnings;

# @constant: string: PWD       : The persent working directory of the this class.
# @constant: array : EXCEPTIONS: The built in exceptions and their corresponding exit codes for the Exception class.
use constant PWD => $ENV{PWD} =~ s/\/\w+$//r;
use constant EXCEPTIONS => {
	'InvalidConfiguration' => 106, 
	'InitializationError' => 110,
	'IllegalAccessError' => 108, 
	'DatabaseException' => 109,
	'UnexpectedFormat' => 112, 
	'ObscureException' => 104,
	'InvalidArgument' => 113,
	'AccessFailed' => 105,
	'FatalError' => 107,
	'IOError' => 111
};

# @var: array: stack : Will be utilized to store the exception stack.
our @stack;

sub Exception {
	# @property: hash : exception: Will be utilized in order to store exceptions defined by the user at. 
	
	# @constructor
	# @description
	#  Utilized in order to initialize the instance variable exceptions
	#  if called with option hash parameter.
	# @param: hash|optional : Hash that contain a camel case string as the key and integer between 64-104 as the value.
	# @usage:
	#  use constant FAULT = new Exception(\%FAULTS)
	# @example:
	#  use constant FAULTS => { CustomException => 64 };
	#  use constant FAULT = new Exception(\%FAULTS); 
	# @public
	sub new {
		my $class = shift;
		my $self = {};
		
		if (@_) {
			throw("InvalidArgument", "Incorrect number of arguments expected 1 received " . scalar(@_)) unless scalar(@_) == 1;
			throw("InvalidArgument", "Incorrect data type expected a hash, received " . ref($_[0])) unless ref($_[0]) eq "HASH";
		}

		$self->{exception} = shift if (@_);

		bless $self, $class;
		return $self;
	}

	# @function: incite
	# @description:
	#  Sets the exception `stack` variable to the exception and the corresponding stack trace.
	# @public
	# @param: string: The exception
	# @param: string: The corresponding message
	sub incite{
		my $self = shift if( scalar @_ >= 3 && ref($_[0]) eq __PACKAGE__ );

		throw("InvalidArgument", "Incorrect number of arguments expected 2 received " . scalar @_) unless scalar @_ == 2;

		my($excp, $excp_msg) = @_;
		my($frame, @details);
		my $date = sub {`date +%Y%m%d" "%H:%M:%S | tr -d '\n'`};

		@details = defined(caller(2)) ? (caller(2)) : (caller(1));	
		$stack[0] = &$date . " $details[3]::$details[2]: $excp: $excp_msg";
		undef @details;

		while ( (@details = (caller($frame++))) ) {
			push @stack, &$date() . " $details[1]::$details[2] package $details[1] function $details[3]" unless $frame < 3; 
		}

		map undef $_, $frame, @details, $excp, $excp_msg, $date;

		return defined($self) ? $self : 1;
	}

	# @function: excp.throw
	# @description:
	#  If provided with the corresponding exception and message will output the exception and message to
	#  standard error. If `incite` was called before hand will output the content of the `stack`
	#  to stanard error.
	# @public
	# @param: self|optional    : Reference to parent class.
	# @param: string|optional  : The exception
	# @param: string|optional  : The corresponding message.
	# @param: function|optional: Optional function to execute prior to throwing the exception.
	# @usage: 
	#  throw [EXCEPTION]... [DETAILS]... [ [FUNCTION]... || ]....
	# @example:
	#  throw "InvalidArgument" "The provided argument is invalied, expected foo not bar"
	sub throw{
		my $self = shift if( scalar @_ >= 3 && ref($_[0]) eq __PACKAGE__ );

		throw("InvalidArgument", "Incorrect number of arguments expected 2 or 3 received " . scalar @_) if (!@stack && (scalar @_ < 2 || scalar @_ > 3));
		
		my $terms = defined($self) ? sub { return defined(EXCEPTIONS->{$_[0]}) || defined($self->{exception}->{$_[0]}); } : sub { return defined(EXCEPTIONS->{$_[0]}); };
		
		throw("InvalidArgument", "$_[0], is not a valid exception") unless &$terms;

		my($excp, $excp_msg, $task) = @_;

		incite($excp, $excp_msg) if !@stack;

		&$task if defined($task);
	
		my($format, $offset);
	
		for my $s (0 .. $#stack) {
			$offset = $s != 0 ? length($stack[$s]) + 5 : 0;
			$format = "%${offset}s\n";
			printf( STDERR $format, $stack[$s] );
		}

		map undef $_, $format, $offset, $excp_msg, $task;
		
		exit(defined(EXCEPTIONS->{$excp}) ? EXCEPTIONS->{$excp} : $self->{exception}->{$excp});
	}

	return 1;
}

Exception;

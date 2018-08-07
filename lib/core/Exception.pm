#!/usr/bin/env perl

# @name: Exception.pm
# @class: Exception
# @author: Gregory Rose
# @created: 20180725
# @modified: 20180807
# @version: 0.05

package Exception;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(incite throw try catch);
@EXPORT_OK = qw(@stack);

# @constant: string: PWD       : The persent working directory of the this class.
# @constant: array : EXCEPTIONS: The built in exceptions and their corresponding exit codes for the Exception class.
use constant PWD => $ENV{PWD} =~ s/\/\w+$//r;
use constant EXCEPTIONS => {
	'InvalidConfiguration' => 106, 
	'InitializationError' => 110,
	'ArgumentCountError' => 103,
	'IllegalAccessError' => 108, 
	'DatabaseException' => 109,
	'UnexpectedFormat' => 112, 
	'ObscureException' => 104,
	'DomainException' => 102,
	'InvalidArgument' => 113,
	'AccessFailed' => 105,
	'FatalError' => 107,
	'TypeError' => 101,
	'IOError' => 111
};

use strict;
use warnings;

# @var: array  : stack   : Will be utilized to store the exception stack.
# @var: integer: code    : Will be utilized to store the corresponding exit code for the exception.
# @var: string : excp    : Will be utilized to store the exception used call either incite or throw.
# @var: string : excp_msg: Will be utilized to store the exception message used to call either incite or throw.
# @var: code   : task    : Will be utilized to store a subroutine to execute prior to exit.
our ( @stack, $code, $excp, $excp_msg, $task );

sub Exception {
	# @constructor
	# @description
	#  Utilized in order to initialize the instance variable exceptions
	#  if called with option hash parameter.
	# @property: hash: exception: Will be utilized in order to store exceptions defined by the user at. 
	# @param: hash|optional : Hash that contain a camel case string as the key and integer between 64-90 as the value.
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
			throw("ArgumentCountError", "Incorrect number of arguments expected 1 received " . scalar(@_)) unless scalar(@_) == 1;
			throw("TypeError", "Incorrect data type expected a hash, received " . ref($_[0])) unless ref($_[0]) eq "HASH";
		}

		$self->{exception} = shift if (@_);

		my $checkExitCode = sub {
			throw("DomainException", "The provided exit code '$_[0]' does not fall within the 64-90 domain") unless $_[0] >= 64 && $_[0] <= 90;
		};

		foreach my $key (keys $self->{exception}) {
			throw("InvalidArgument", "Exception '${key}' already exist in the default exception list") if defined(EXCEPTIONS->{$key});
			&$checkExitCode($self->{exception}->{$key});
		}

		bless $self, $class;
		return $self;
	}
	
	# @function: setExceptionParameters
	# @description:
	#   Utilized in order to set the neccessary parameters for the Exception module/class.
	# @param: self|optional: Reference to parent class.
	# @param: scalar       : The exception
	# @param: scalar       : The corresponding message.
	# @param: code|optional: Optional function to execute prior to throwing the exception.
	# @private 
	sub setExceptionParameters {
		my $self = shift if( scalar @_ >= 3 && ref($_[0]) eq __PACKAGE__ );

		throw("ArgumentCountError", "Incorrect number of arguments expected 2 or 3 received " . scalar @_) if (!@stack && (scalar @_ < 2 || scalar @_ > 3));

		my $terms = defined($self) ? sub { return defined(EXCEPTIONS->{$_[0]}) || defined($self->{exception}->{$_[0]}); } : sub { return defined(EXCEPTIONS->{$_[0]}); };

		throw("DomainException", "$_[0], is an unregistered exception") unless &$terms;
		
		defined($_[2]) && do {
			throw( "TypeError", "A subroutine is expected as the third parameter for incite/throw" ) unless ref($_[2]) eq 'CODE';
		};

		$excp = shift;
		$excp_msg = shift;
		$task = shift;

		return defined($self) ? $self : 1;
	}

	# @function: incite
	# @description:
	#  Sets the exception `stack` variable to the exception and the corresponding stack trace.
	# @param: self|optional  : Reference to parent class. 
	# @param: string|optional: The exception
	# @param: string|optional: The corresponding message
	# @param: code|optional  : Optional function to execute prior to throwing the exception.
	# @public
	sub incite{
		my $self = shift if( ref($_[0]) eq __PACKAGE__ );
		do {
			unless(defined($self)) {
				setExceptionParameters(@_);
			} else {
				$self->setExceptionParameters(@_);
			}
		} unless(defined($excp) && defined($excp_msg));

		my($frame, @details);
		my $date = sub {`date +%Y%m%d" "%H:%M:%S | tr -d '\n'`};

		@details = defined(caller(2)) ? (caller(2)) : (caller(1));

		throw("FatalError", "`incite` most be called from within a subroutine")	unless defined($details[3]);

		$stack[0] = &$date . " $details[3]::$details[2]: $excp: $excp_msg";
		undef @details;

		while ( (@details = (caller($frame++))) ) {
			push @stack, &$date() . " $details[1]::$details[2] package $details[1] function $details[3]" unless $frame < 3; 
		}

		$code = defined(EXCEPTIONS->{$excp}) ? EXCEPTIONS->{$excp} : $self->{exception}->{$excp};
		map undef $_, $frame, @details, $date;

		return defined($self) ? $self : 1;
	}

	# @function: throw
	# @description:
	#  If provided with the corresponding exception and message will output the exception and message to
	#  standard error. If `incite` was called before hand will output the content of the `stack`
	#  to stanard error.
	# @param: self|optional  : Reference to parent class.
	# @param: string|optional: The exception
	# @param: string|optional: The corresponding message.
	# @param: code|optional  : Optional function to execute prior to throwing the exception.
	# @usage: 
	#  throw [EXCEPTION]... [DETAILS]... [ [FUNCTION]... || ]....
	# @example:
	#  throw "InvalidArgument" "The provided argument is invalied, expected foo not bar"
	# @public
	sub throw{
		my $self = shift if( ref($_[0]) eq __PACKAGE__ );
		do {
			unless(defined($self)) {
				setExceptionParameters(@_);
			} else {
				$self->setExceptionParameters(@_);
			}
		} unless(defined($excp) && defined($excp_msg));

		&$task if defined($task);

		!@stack && do {
			if(defined($self)) {
				$self->incite; 
			} else {
				incite; 
			}
		};
	
		my($format, $offset);
	
		for my $s (0 .. $#stack) {
			$offset = $s != 0 ? length($stack[$s]) + 5 : 0;
			$format = "%${offset}s\n";
			printf( STDERR $format, $stack[$s] );
		}

		map undef $_, $format, $offset, $task;
	
		exit($code);
	}


	# @function: try
	# @description:
	#   Attempts to execute the provided code block, and capture the exit code.
	#   It then execute the corresponding catch function making available the exit code.
	# @param: code  : The code block to execute.
	# @param: scalar: A reference to the catch subroutine.
	# @param: scalar: Absolute path to a log file in which to write STDERR.
	# @public
	sub try(&$) {
		my($try, $catch, $log) = @_;
		my $child = fork();

		unless($child){
			&$try
		} else {
			my $pid = wait();

			throw("ObscureException", "No child process was created.") if $pid < 0;

			local $_ = $? >> 8;
			&$catch
		}

		return 1;
	}

	# @function: catch
	# @description:
	#   An identity function that will return the results of the provided code block.
	# @param: code: The code block to execute.
	# @public
	sub catch(&) { $_[0] }

	# @function: getStack
	# @description:
	#   Return the stack array to the caller.
	# @public
	sub getStack { return @stack }	

	return 1;
}

Exception;

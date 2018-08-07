#!/usr/bin/env perl

# @name: UnitTest.pm
# @module: UnitTest
# @author: Gregory Rose
# @created: 20180802
# @modified: 20180803
# @version: 0.02
# @description:
# 	When used, provides a set of methods that can be utilized in order to unit test classes, modules, and processes.

package UnitTest;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(unitTest assertEquals);

use STD;
use Exception;
use strict;
use warnings;

sub UnitTest {
	
	# @function: runMultiInput
	# @description:
	# 	Run the provided function with multiple arguments, up to two presently.
	# @public
	# @param: hash: A hash containing the function to execute, desires message, expected exit code, and an array of parameters.
	sub unitTest(@) {
		my $units = shift;
		foreach my $unit (@$units) {
			&{sub{
				local $_ = shift;
				my $index = { message => "$unit->{message}", expect => "$unit->{expect}" };
				/0/ && assertEquals( sub { $unit->{function}() }, $index );
				/1/ && assertEquals( sub { $unit->{function}( $unit->{params}->[0] ) }, $index );
				/2/ && assertEquals( sub { $unit->{function}( $unit->{params}->[0], $unit->{params}->[1] ) }, $index );
				/3/ && assertEquals( sub { $unit->{function}( $unit->{params}->[0], $unit->{params}->[1], $unit->{params}->[2] ) }, $index );
				/4/ && assertEquals( sub { $unit->{function}( $unit->{params}->[0], $unit->{params}->[1], $unit->{params}->[2], $unit->{params}->[3] ) }, $index );
			}}(scalar @{ $unit->{params} });
		};

		return 1;
	}


	# @function: assertEquals
	# @description:
	# 	Determines if the expected out come matches the actual out come. 
	# 	If the expected out come matches the expected then the function
	# 	outputs the provided message and "passed". If they do not match, 
	# 	the function then outputs the provided message and "failed"
	# @param: subroutine: The desired subroutine to test.
	# @param: hash      : Hash containing desire message and expected exit code.
	# @public
	sub assertEquals(&%) {
		my($function, $index) = @_;
		chomp(my $timestamp = `date +%Y%m%d%H%M%S%N`);
		my $client = (caller(1))[1]; $client =~ s/^(\/)?.+\///;
    	my $error = TEMP . '/' . ${client} . '.' . ${timestamp} . '.log';
		
		try {
			open(STDERR, ">${error}") || throw("FatalError", "Failed to redirect STDERR to ${error} ($!)");
			#open(STDOUT, ">/dev/null") || throw("FatalError", "Failed to redirect STDOUT to '/dev/null' ($!)");
			&$function
		} catch {
			if( $_ == $index->{expect} ) {
				output($index->{message}, "PASSED");
				unlink $error;
			} else {
				output($index->{message}, "---->FAILER!?!: EXPECTED = $index->{expect} ACTUAL = $_", $error);
				unlink $error;
				exit 1;
			}
#			/$index->{expect}/ && do {
#				print "Why am I here A2\n";
#				output($index->{message}, "PASSED");
#				unlink $error;
#			} || do {
#				print "I made here A1\n";
#				output($index->{message}, "---->FAILER!?!: EXPECTED = $index->{expect} ACTUAL = $_", $error);
#				unlink $error;
#				exit 1;
#			}
		};

		return 1;
	}


	# @function: output
	# @description:
	# 	Formats and outputs the provided strings
	# @param: string         : The message
	# @param: string         : Test result
	# @param: string|optional: The absolute path to a corresponding log file. 
	# @private
	sub output {
		my ($message, $result, $error) = @_;

		my $out = "${message}: ${result}";
		my $format = '%' . do{ length($out) + 4 } . "s\n";
	
		printf("${format}", "${out}");
		defined($error) && do {
			open (my $fh, $error) || throw("FatalError", "Failed to open file ${error} ($!)");
			while (<$fh>) { 
				my $format = '%' . do{ length($_) +  5 } . "s";
				printf("${format}", "$_"); 
			}
		};

		return 1;
	}

	return 1;
}

UnitTest;

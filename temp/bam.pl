#!/usr/bin/env perl

use Exception;
use Data::Dumper;
#print defined(try) . "\n";
#print defined(catch) . "\n";


# subroutine to pass to fork function.
sub passMe {
	print "I am going to sleep for .5 sec then exit 64\n";
	sleep 1;
	exit 64;
	#return 1;
}

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
	exit 66;
}
#bar;

my @ERROR = (
#	{
#		function => sub { Exception->new(@_); },
#		message  => 'Exception::new - Attempt to call new with more than one parameter',
#		expect   => 113,
#		params   => [ 'foo', 'bar' ],
#	}
	{
		function => sub { print "Heavy whippint cream\n"; exit 64; },
		message  => 'Testing::123 - Attempt to test it out',
		expect   => 64,
		params   => []
	},
	{
		function => sub { print "Hot bread $_[0] \n"; exit 65; },
		message  => 'Testing::456 - Attempting to test out again',
		expect   => 67,
		params   => [ 'yea' ]
	},
	{
		function => \&bar,
		message  => 'Testing::bar - Attempting to test out once again',
		expect   => 66,
		params   => [ 'hell', 'yea' ]
	}
);

#$ERROR[0]{function}(join(",", $ERROR[0]{params}));

use constant TEMP => '/home/rosegr01/Developer/perl/temp';

#print "Error captured : $@\n";
#print "testing " . $ERROR[0]{message} . "\n";
#print "testing " . $ERROR[0]{expect} . "\n";
#print "testing " . $ERROR[0]{params}[1]. "\n";
sub output {
	my ($message, $result) = @_;

	my $out = "${message}: ${result}";
	my $form = '%' . do{ length($out) + 4 } . "s\n";
	
	printf("${form}", "${out}");

	return 1;
}

sub assertEquals(&%) {
	my($function, $index) = @_;
	chomp(my $timestamp = `date +%Y%m%d%H%M%S%N`);
	#my $client = (caller(1))[1]; $client =~ s/^(\/)?.+\///;
	my $client = (caller(0))[1]; $client =~ s/^(\/)?.+\///;
    my $error = TEMP . '/' . ${client} . '.' . ${timestamp} . '.log';
		
	try {
		open(STDERR, ">${error}") || throw("FatalError", "Failed to redirect STDERR to ${error} ($!)");
		open(STDOUT, ">/dev/null") || throw("FatalError", "Failed to redirect STDOUT to '/dev/null' ($!)");
		&$function
	} catch {
		/$index->{expect}/ && do {
			output($index->{message}, "PASSED");
			unlink $error;
		} || do {
			output($index->{message}, "---->FAILER!?!: EXPECTED = $index->{expect} ACTUAL = $_");
			open (my $fh, $error) || throw("FatalError", "Failed to open file ${error} ($!)");
			while (<$fh>) { print $_; }
			unlink $error;
			exit 1;
		}
	};

	return 1;
}

sub unitTest(@) {
	my $units = shift;
	foreach my $unit (@$units) {
		&{sub{
			local $_ = shift;
			local $index = { message => "$unit->{message}", expect => "$unit->{expect}" };
			/0/ && assertEquals { $unit->{function}() } $index;
			/1/ && assertEquals { $unit->{function}( $unit->{params}->[0] ) } $index;
			/2/ && assertEquals { $unit->{function}( $unit->{params}->[0], $unit->{params}->[1] ) } $index;
		}}(scalar @{ $unit->{params} });
	};

	return 1;
}

#unitTest \@ERROR;
#&{sub{
#	local $_ = shift;
#	/burger/ && { print "Clean and out\n" } || {print "no go\n"};
#}}('fries');

sub letsSee() {
	chomp(my $timestamp = `date +%Y%m%d%H%M%S%N`);
	#my $client = (caller(1))[1]; $client =~ s/^(\/)?.+\///;
	my $client = (caller(0))[1]; $client =~ s/^(\/)?.+\///;
    my $error = TEMP . '/' . ${client} . '.' . ${timestamp} . '.log';
		
	try {
		local *STDOUT;
		open(STDERR, ">${error}")  || throw("FatalError", "Failed to redirect STDERR to ${error} ($!)");
		throw("InvalidArgument", "This is a test error")
	} catch {
		/112/ && do { 
			print "FIRE \n"; unlink $error; 
		} || do {
			open (my $fh, $error) || throw("FatalError", "Failed to open file ${error} ($!)");
			while (<$fh>) { print $_; }
		}
	};
}

incite("TypeError", "This is a test");
throw;

#letsSee;
#my $script = (caller(1))[1]; $script =~ s/^(\/)?.+\///;
#open(STDERR, ">> log.out") || throw("FatalError", "Failed to redirect STDERR ($!)");
#my $v = '/This/Is/The/same/as/basename/bam.pl';
#my $v = '/This/Is/The/same/as/basename/5';
#print $v . "\n";
#$v =~ s/^(\/)?.+\///;
#$v =~ s/\/\w+(\.\w+)?$//;
#print $v . "\n";
#print $0 . "\n";
#chomp(my $time = `date +%Y%m%d%H%M%S`);
#print LOG . '/' . ${v} . '.' . ${time} . '.log' . "\n"; 

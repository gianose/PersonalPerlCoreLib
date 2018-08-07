#!/usr/bin/env perl


# subroutine to pass to fork function.
sub passMe {
	print "I am going to sleep for .5 sec then exit 64\n";
	sleep 1;
	exit 64;
	#return 1;
}

# The for function
sub forkIt {
	my $child = fork();

	unless ($child){
		passMe;
	} else {
		wait();

		my $status = $?;
		my $exit = $? >> 8;

		print "Full status = $status (exit=$exit)\n";
	}
}

#forkIt;

sub try(&$) {
	print "I am in \n";
	my($try, $catch) = @_;

	print "Creating th fork\n";
	my $child = fork(); #|| die "I failed you";

	unless($child){
		&$try
	} else {
		wait();
		local $_ = $? >> 8;

		&$catch
	}
}

sub catch(&) { $_[0] }

sub letsSee(&%) {
	print $_[0] . "\n";
	print $_[1] . "\n";
	my($lets, %see) = @_;
	print $lets . "\n";
	print $see{1} . "\n";
	print $see{3} . "\n";
	print $see{5} . "\n";

	print ref($lets) . "\n";
	print ref(\%see) . "\n";

	return 1;
}

#letsSee { print "this is a function\n"; } qw(1 2 3 4 5 6);

try {
	passMe;
} 
catch {
	/64/ && print "Hello There\n";
}

#$h = {
#	a => 1,
#	b => 2
#};

#foreach my $key (keys $h) {
#	print "key = ${key}, value = $h->{$key}\n"  
#}

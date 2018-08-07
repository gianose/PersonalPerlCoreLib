#!/usr/bin/env perl

# @name: STD.pm
# @module: STD
# @author: Gregory Rose
# @created: 20180803
# @modified: n/a
# @version: 0.01
# @descrition:
#   Provides a set of static variables and functions for all modules and scripts.
# @requires
#   lib/core/Exception.pm

package STD;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(BIN LIB TEMP);

# @constant: string: NAMESPACE: The root directory of the entire application.
# @constant: string: TEMP     : The absolute path to the temp DIR as it relates to the script.
# @constant: string: BIN      : The absolute path to the bin DIR as it relates to the script.
# @constant: string: LIB      : The absolute path to the lib DIR as it relates to the script.
use constant NAMESPACE => $ENV{PWD} =~ s/(\/\w+){1}$//r;
use constant TEMP      => NAMESPACE . '/temp';
use constant BIN       => NAMESPACE . '/bin';
use constant LIB       => NAMESPACE . '/lib';

#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::Builtin::Sugar' );
}

diag( "Testing File::Builtin::Sugar $File::Builtin::Sugar::VERSION, Perl $], $^X" );

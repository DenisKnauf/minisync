#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(strftime);
$|++;

END { wait; };

$SIG{CLD} = sub {
	wait;
	exit $?;
};

sub mj {
	%_ = @_;
	'{ts:"'.strftime( '%Y-%m-%d %H:%M:%S', localtime).'", proc:"s", '.join( ', ', map "$_:\"$_{$_}\"", keys%_)."}\n";
}

sub readg {
	my $data = '';
	while( length( $data) < $_[0]) {
		read( STDIN, $data, $_[0]-length($data), length($data)) or return(0);
	}
	$data;
}

chdir $ARGV[0] or die( mj( error=>'cannot_chdir', exception=>$!));
while( my$data = readg(6)) {
	my( $cmd, $length) = unpack( 'nN', $data);
	$data = readg $length;
	if( 1 == $cmd) {
		open( F, '>>', $data)  or  die( mj( error=>'unable_to_open_file', message=>"Can't open file <$data>"));
		my@stat = stat F;
		print pack( 'N', $stat[7]);
	}
	elsif( 2 == $cmd) {
		print F $data;
	}
	else { 
		die( mj( error=>'unknown_command', command=>$cmd));
	}
}
exit 0;

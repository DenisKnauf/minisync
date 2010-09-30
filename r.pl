#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(strftime);
$|++;

sub ts {
	strftime '%Y-%m-%d %H:%M:%S', localtime;
}

$SIG{CLD} = sub {
	wait;
	#printf STDERR "{ts: \"".ts."\", proc: \"r\", action: \"exit\", code: $?, error: \"child_died\"}\n";
	exit $?;
};

sub readcmd {
	my $data = '';
	while( length( $data) < 6) {
		read( STDIN, $data, 6-length($data), length($data)) or return(0);
	}
	$data;
}

chdir $ARGV[0] or die( "{ts: \"".ts."\", proc: \"r\", error: \"cannot_chdir\", exception: \"$!\"}\n");
while( my$data = readcmd) {
	(my$cmd, my$length) = unpack( 'nN', $data);
	#print STDERR "{ts: \"".ts."\", cmd: $cmd, length: $length}\n";
	read STDIN, $data, $length;
	if( 1 == $cmd) {
		open( F, '>>', $data)  or  die( "{ts: \"".ts."\", proc: \"r\", error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}\n");
		my@stat = stat F;
		print pack( 'N', $stat[7]);
	}
	elsif( 2 == $cmd) {
		print F $data;
	}
	else { 
		die( "{ts: \"".ts."\", proc: \"r\", error: \"unknown_command\", command: $cmd}\n");
	}
}
#print STDERR "{ts: \"".ts."\", proc: \"r\", exit: 0}\n";
exit 0;

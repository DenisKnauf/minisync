#!/usr/bin/env perl

use strict;
use warnings;
$|++;

$SIG{CLD} = sub {
	wait;
	printf STDERR "{proc: \"r\", action: \"exit\", code: $?, error: \"child_died\"}\n";
	exit $?;
};

sub readcmd {
	my $data = '';
	while( length( $data) < 6) {
		read( STDIN, $data, 6-length($data), length($data)) or return(0);
	}
	$data;
}

chdir $ARGV[0] or die( "{proc: \"r\", error: \"cannot_chdir\", exception: \"$!\"}\n");
while( my$data = readcmd) {
	(my$cmd, my$length) = unpack( 'nN', $data);
	print STDERR "{cmd: $cmd, length: $length}\n";
	read STDIN, $data, $length;
	if( 1 == $cmd) {
		open( F, '>>', $data)  or  die( "{proc: \"r\", error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}\n");
		my@stat = stat F;
		print pack( 'N', $stat[7]);
	}
	elsif( 2 == $cmd) {
		print F $data;
	}
	else { 
		die( "{proc: \"r\", error: \"unknown_command\", command: $cmd}\n");
	}
}
print STDERR "{proc: \"r\", exit: 0}\n";
exit 0;

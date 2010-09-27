#!/usr/bin/env perl

use strict;
use warnings;
$|++;

$SIG{CLD} = sub {
	wait;
	printf STDERR "{proc: \"r\", action: \"exit\", code: 1, error: \"child_died\"}\n";
	exit 1;
};

sub readcmd {
	my $data = '';
	while( length( $data) < 6) {
		read( STDIN, $data, 6-length($data), length($data)) or return(0);
	}
	$data;
}

while( my$data = readcmd) {
	(my$cmd, my$length) = unpack( 'nN', $data);
	print STDERR "{cmd: $cmd, length: $length}\n";
	read STDIN, $data, $length;
	if( 1 == $cmd) {
		print STDERR "{proc: \"r\", action: \"open\", file: \"$data\"}\n";
		open( F, '>>', $data) or print STDERR ("{proc: \"r\", error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}\n");
		my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat F;
		print pack( 'N', $size);
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

#!/usr/bin/env perl

use strict;
use warnings;
$|++;

$SIG{CLD} = sub {
	printf STDERR "{proc: \"r\", action: \"child_died\"}\n";
	wait;
	printf STDERR "{proc: \"r\", action: \"exit\", code: 0}\n";
	exit 0;
};

my @cmds = (
	1 => 'file',
	2 => 'content'
);

print STDERR "r << s";

sub readcmd {
	my $data = '';
	while( length( $data) < 6) {
		read( STDIN, $data, 6-length($data), length($data)) or return(0);
	}
	$data;
}

while( my$data = readcmd) {
	printf STDERR "{proc: \"r\", read_length: %d}\n", length( $data);
	(my$cmd, my$length) = unpack( 'nN', $data);
	print STDERR "{cmd: $cmd, length: $length}\n";
	print STDERR "r << s\n";
	read STDIN, $data, $length;
	if( 1 == $cmd) {
		print STDERR "{proc: \"r\", action: \"open_file\", file: \"$data\"}\n";
		open( F, '>>', $data) or print STDERR ("{proc: \"r\", error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}\n");
		my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat F;
		print STDERR "r >> s\n";
		print pack( 'N', $size);
	}
	elsif( 2 == $cmd) {
		print STDERR "r >> f\n";
		print F $data;
	}
	else { 
		die( "{proc: \"r\", error: \"unknown_command\", command: $cmd}\n");
	}
}
print STDERR "{proc: \"r\", exit: 0}\n";
exit 0;

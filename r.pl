#!/usr/bin/env perl

while( read( STDIN, my $data, 6)) {
	my( $cmd, $length) = unpack 'nN', $data;
	read STDIN, my $data, $length;
	if( 1 == $cmd) {
		print STDERR "{proc: \"r\", action: \"open_file\", file: \"$data\"}\n";
		open( F, '>>', $data) or print STDERR ("{proc: \"r\", error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}\n");
		my( $dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
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

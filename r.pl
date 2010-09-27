#!/usr/bin/env perl

while( read STDIN, my $data, 6) {
	my( $cmd, $length) = unpack 'nN', $data;
	read STDIN, my $data, $length;
	if( 1 == $cmd) {
		print STDERR "{action: \"open_file\", file: \"$data\"}";
		open( F, '>>', $data) or print STDERR ("{error: \"unable_to_open_file\", message: \"Can't open file <$data>.\"}");
		my( $dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat F;
		print pack( 'N', $size);
	}
	elsif( 2 == $cmd) {
		print F, $data;
	}
	else
		exit(1);
}

#!/usr/bin/env perl

use strict;
#use warnings; # Old perl
use POSIX qw(strftime);
$|++;

sub ts {
	strftime '%Y-%m-%d %H:%M:%S', localtime;
}

my$dir = shift @ARGV;
$dir =~ /^(\/.*)\/([^\/]+)$/ or die( "{ts: \"".ts."\", proc: \"s\", error: \"invalid_path_expression\", message: \"Path-Expression is invalid.\"}\n");
($dir, my$fexpr) = ($1, $2);

chdir( $dir) or die( "{ts: \"".ts."\", proc: \"s\", error: \"change_directory\", value: \"$dir\", message: \"$!\"}\n");
opendir( DH, '.') || die "{ts: \"".ts."\", proc: \"s\", error: \"dir_not_found\", message: \"Directory not found.\"}\n";
while( my$filename = readdir( DH)) {
	$filename =~ /$fexpr/ or next;
	-f $filename or next;
	print pack( 'nNA*', 1, length($filename), $filename);
	print STDERR "{ts: \"".ts."\", proc: \"s\", action: \"open\", file: \"$filename\"}\n";
	open F, $filename;
	read STDIN, my$length, 4; # Was wenn < 4 ?
	$length = unpack 'N', $length;
	seek F, $length, 0;
 	while( read( F, my$r, 1400)) {
		print pack( 'nNA*', 2, length($r), $r);
	}
	print STDERR "{ts: \"".ts."\", proc: \"s\", action: \"close\", file: \"$filename\"}\n";
	close F;
}
closedir DH;
print STDERR "{ts: \"".ts."\", proc: \"s\", exit: 0}\n";
exit( 0);

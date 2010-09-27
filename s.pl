#!/usr/bin/env perl

use strict;
use warnings;
$|++;

my$dir = shift @ARGV;
$dir =~ /^(\/.*)\/([^\/]+)$/ or die( "{proc: \"s\", error: \"invalid_path_expression\", message: \"Path-Expression is invalid.\"}\n");
($dir, my$fexpr) = ($1, $2);

chdir( $dir) or die( "{proc: \"s\", error: \"change_directory\", value: \"$dir\", message: \"$!\"}\n");
opendir( my$dh, '.') || die "{proc: \"s\", error: \"dir_not_found\", message: \"Directory not found.\"}\n";
while( my$filename = readdir( $dh)) {
	$filename =~ /$fexpr/ or next;
	-f $filename or next;
	print pack( 'nN/A*', 1, $filename);
	print STDERR "{proc: \"s\", action: \"open\", file: \"$filename\"}\n";
	open F, $filename;
	read STDIN, my$length, 4; # Was wenn < 4 ?
	$length = unpack 'N', $length;
	seek F, $length, 0;
 	while( read( F, my$r, 2040)) {
		print pack( 'nN/A*', 2, $r);
	}
	print STDERR "{proc: \"s\", action: \"close\", file: \"$filename\"}\n";
	close F;
}
closedir $dh;
print STDERR "{proc: \"s\", exit: 0}\n";
exit(0);

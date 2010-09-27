#!/usr/bin/env perl

my $dir = shift @ARGS;
$dir =~ /^(\/.*)\/[^/]*$/ or die( '{error: "invalid_path_expression", message: "Path-Expression is invalid."}');
$dir, my $fexpr = $1, $2;
$fexpr = /$fexpr/;

opendir( my $dh, $dir) || die '{error: "dir_not_found", message: "Directory not found."}';
while( $filename = readdir( $dh)) {
	print pack( 'nN/(A*)', 1, $filename);
	open F, $filename;
	read STDIN, my $length, 4; # Was wenn < 4 ?
	seek F, $length, SEEK_SET;
	print pack( 'nN/(A*)', 2, $r)  while read( F, $r, 2048);
	close F;
}
closedir $dh;

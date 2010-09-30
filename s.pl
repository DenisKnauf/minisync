#!/usr/bin/env perl

use strict;
use POSIX qw(strftime);
$|++;

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

my$dir = shift @ARGV;
$dir =~ /^(\/.*)\/([^\/]+)$/ or die( mj( error=>'invalid_path_expression', message=>'Path-Expression is invalid.'));
($dir, my$fexpr) = ($1, $2);

chdir( $dir) or die( mj( error=>'change_directory', value=>$dir, message=>$!));
opendir( DH, '.') or die( mj( error=>'dir_not_found', message=>'Directory not found.'));
while( my$filename = readdir( DH)) {
	next  unless $filename =~ /$fexpr/ and -f $filename;
	print pack( 'nNA*', 1, length($filename), $filename);
	open F, $filename;
	my$length = readg 4;
	$length = unpack 'N', $length;
	seek F, $length, 0;
 	while( read( F, my$r, 1400)) {
		print pack( 'nNA*', 2, length($r), $r);
	}
	close F;
}
closedir DH;
exit( 0);

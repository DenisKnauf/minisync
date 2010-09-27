#!/usr/bin/env perl

my $dir = shift @ARGV;
$dir =~ /^(\/.*)\/([^\/]+)$/ or die( "{proc: \"s\", error: \"invalid_path_expression\", message: \"Path-Expression is invalid.\"}\n");
($dir, my( $fexpr)) = ($1, $2);

print STDERR $fexpr;

chdir( $dir) or die( "{proc: \"s\", error: \"change_directory\", value: \"$dir\", message: \"$!\"}\n");
opendir( my( $dh), '.') || die "{proc: \"s\", error: \"dir_not_found\", message: \"Directory not found.\"}\n";
while( $filename = readdir( $dh)) {
	print STDERR "{proc: \"s\", action: \"find\", file: \"$filename\"}\n";
	$filename =~ /$fexpr/ or next;
	print pack( 'nN/(A*)', 1, $filename);
	print STDERR "{proc: \"s\", action: \"open\", file: \"$filename\"}\n";
	open F, $filename;
	read STDIN, my $length, 4; # Was wenn < 4 ?
	seek F, $length, SEEK_SET;
	print pack( 'nN/(A*)', 2, $r)  while read( F, $r, 2048);
	print STDERR "{proc: \"s\", action: \"close\", file: \"$filename\"}\n";
	close F;
}
closedir $dh;
print STDERR "{proc: \"s\", exit: 0}\n";
exit(0);

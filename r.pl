#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(strftime);

my$child = 0;
__FILE__ =~ /^(.*\/)?[^\/]*?$/;
my$libexec = $1 || '.';

END {
	print STDERR "\n";
	kill $child, 15;
	waitpid $child, 0;
	exit $?;
}

$SIG{CLD} = $SIG{INT} = sub { exit; };

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

sub shdump {
	my$r = $_[0];
	$r =~ s/[\\']/\'\\$&\'/g;
	"'".$r."'";
}

my( $machine, $source, $destination) = @ARGV;

pipe SIN, ROUT;
pipe RIN, SOUT;

unless( $child = fork()) {
	open F, '<', "$libexec/s.pl" or die( mj( error=>'cannot_open_s.pl', exception=>$!));
	sysread F, my $s_pl, -s F;
	close F;
	close ROUT;
	close RIN;
	open STDOUT, '>&', \*SOUT;
	open STDIN, '<&', \*SIN;
	exec 'ssh', $machine, 'perl', '-e', shdump($s_pl), shdump($source);
}

close SOUT;
close SIN;
open STDOUT, '>&', \*ROUT;
open STDIN, '<&', \*RIN;
$|++;

my@f;
chdir $destination or die( mj( error=>'cannot_chdir', exception=>$!));
while( my$data = readg(6)) {
	my( $cmd, $length) = unpack( 'nN', $data);
	$data = readg $length;
	if( 1 == $cmd) {
		print STDERR "\n"  if $f[0];
		open( F, '>>', $data)  or  die( mj( error=>'unable_to_open_file', message=>"Can't open file <$data>"));
		@f = ($data, -s F);
		print pack( 'N', $f[1]);
	}
	elsif( 2 == $cmd) {
		$f[1] += length $data;
		print F $data;
	}
	else { 
		die( mj( error=>'unknown_command', command=>$cmd));
	}
	printf STDERR "\r% 14d %s", $f[1], $f[0];
}
exit;

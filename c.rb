#!/usr/bin/env ruby

tor = IO.pipe
tos = IO.pipe

fork do
	$stdin.reopen tor.first
	$stdout.reopen tos.last
	exec 'ssh', ARGV[0], 'perl', 'r.pl', ARGV[1]
end

$stdin.reopen tos.first
$stdout.reopen tor.last
exec 'perl', 's.pl', ARGV[2]

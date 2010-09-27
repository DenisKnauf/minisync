#!/usr/bin/env ruby

class IO
	def readall
		buf = ''
		loop do
			buf << begin
					self.sysread 4096
				rescue EOFError
					return buf
				end
		end
	end
end

class String
	def shdump
		"'#{gsub( /[\\']/, '\'\\\\\&\'')}'"
	end
end

class File
	def self.readall file
		open( file) {|f| f.readall }
	end
end

tor = IO.pipe
tos = IO.pipe

fork do
	$stdin.reopen tor.first
	$stdout.reopen tos.last
	exec 'ssh', ARGV[0], 'perl', '-e', File.readall( 's.pl').shdump, ARGV[1].shdump
end

$stdin.reopen tos.first
$stdout.reopen tor.last
exec 'perl', 'r.pl', ARGV[2].shdump

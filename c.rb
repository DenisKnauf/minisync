#!/usr/bin/env ruby

require 'json'

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

$tor = tor = IO.pipe
$tos = tos = IO.pipe

if Process.fork
	$stdin.reopen tor.first
	tor.last.close
	$stdout.reopen tos.last
	tos.first.close
	$stderr.puts( {proc: 'c', connect: ARGV[0], args: ARGV[1]}.to_json)
	exec 'ssh', ARGV[0], 'perl', '-e', File.readall( 's.pl').shdump, ARGV[1].shdump
else
	#$stdout.puts 'test'
	#$stderr.print '>> '
	#$stdin.each_line {|l| p eval( l); print '>> ' }

	$stdin.reopen tos.first
	tos.last.close
	$stdout.reopen tor.last
	tor.first.close
	$stderr.puts( {proc: 'c', exec: 'reciever', destination: ARGV[2]}.to_json)
	exec 'perl', 'r.pl', ARGV[2].shdump
end

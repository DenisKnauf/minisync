#!/usr/bin/env ruby

libexec = File.expand_path File.dirname( __FILE__)
machine, source, destination = ARGV[0...3]

def ts
	Time.now.strftime '%Y-%m-%d %H:%M:%S'
end

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

class File
	def self.readall file
		open( file) {|f| f.readall }
	end
end

class String
	def shdump
		"'#{gsub( /[\\']/, '\'\\\\\&\'')}'"
	end
end

$tor = tor = IO.pipe
$tos = tos = IO.pipe

Process.fork do
	$stdin.reopen tor.first
	tor.last.close
	$stdout.reopen tos.last
	tos.first.close
	exec 'ssh', machine, 'perl', '-e', File.readall( File.join( libexec, 's.pl')).shdump, source.shdump
end

$stdin.reopen tos.first
tos.last.close
$stdout.reopen tor.last
tor.first.close
exec 'perl', File.join( libexec, 'r.pl'), destination

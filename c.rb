#!/usr/bin/env ruby

libexec = File.expand_path File.dirname( __FILE__)
machine, source, destination = ARGV[0...3]

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

if Process.fork
	$stdin.reopen tor.first
	tor.last.close
	$stdout.reopen tos.last
	tos.first.close
	$stderr.puts( {:proc => 'c', :machine => machine, :source => source}.inspect)
	exec 'ssh', machine, 'perl', '-e', File.readall( File.join( libexec, 's.pl')).shdump, source.shdump
else
	$stdin.reopen tos.first
	tos.last.close
	$stdout.reopen tor.last
	tor.first.close
	$stderr.puts( {:proc => 'c', :exec => 'reciever', :destination => destination}.inspect)
	exec 'perl', File.join( libexec, 'r.pl'), destination
end

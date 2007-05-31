require 'tempfile'
require 'nodel'

module Gnuplot
	def Gnuplot.plot(script, back = true)
		if script.is_a?(File)
			arg = script.path
		else
			script_file = Tempfile.new('script', Dir::tmpdir, false) # do not unlink
			script_file.puts(script)
			script_file.close
			arg = script_file.path
		end
		command = "gnuplot #{arg}"
		return fork {`#{command}`} if back
		`#{command}`
	end
end

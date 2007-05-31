require 'gnuplot'
require 'matrix'
require 'mapcar'
require 'block'
require 'tempfile'
require 'nodel'


class Vector
	include Enumerable
	module Norm 
		def Norm.sqnorm(obj, p)
      sum = 0
      obj.each{|x| sum += x ** p}
      sum
    end 
	end

	alias :length :size

=begin
	def []=(i, v)
    		@elements[i] = v
	end
=end

	def collect! 
		els = @elements.collect! {|v| yield(v)}
		Vector.elements(els, false)
	end

	def each 
		(0...size).each {|i| yield(self[i])}
		nil
	end

	def max
		to_a.max
	end
  
  def min
    to_a.min
  end

	def norm(p = 2)
    Norm.sqnorm(self, p) ** (Float(1)/p)
  end
  
  def norm_inf
    [min.abs, max.abs].max
  end
	
	def slice(*args)
		Vector[*to_a.slice(*args)]	
	end

	def slice_set(v, b, e)
		for i in b..e
			self[i] = v[i-b]	
		end
	end
	
	def slice=(args)
		case args[1]
		when Range
			slice_set(args[0], args[1].begin, args[1].last)
		else
			slice_set(args[0], args[1], args[2])
		end
	end

	def /(c)
		map {|e| e / c}
	end

	alias :star :*
	
	def *(c)
		case c
		when Numeric
			map {|e| e * c}
		else
			star(c)
		end
	end

	def transpose
		Matrix[self.to_a]
	end
	
	alias :t :transpose
	
	def house
		n = length
		s = slice(1, n)
		sigma = s.inner_product(s)
		v = clone; v[0] = 1
		if sigma == 0
			beta = 0
		else
			mu = Math.sqrt(self[0] ** 2 + sigma)
			if self[0] <= 0
				v[0] = self[0] - mu
			else
				v[0] = -sigma / (self[0] + mu)
			end
			v2 = v[0] ** 2
			beta = 2 * v2 / (sigma + v2)
			v /= v[1]
		end
		return v, beta
	end
end

class Matrix
	include Enumerable
	public_class_method :new

  attr_reader :rows, :wrap
	@wrap = nil
	
	def initialize(*argv)
		return initialize_old(*argv) if argv[0].is_a?(Symbol)
		n, m, val = argv; val = 0 if not val
		f = (block_given?)? lambda {|i,j| yield(i, j)} : lambda {|i,j| val}
		init_rows((0...n).collect {|i| (0...m).collect {|j| f.call(i,j)}}, true)
	end
	
	def initialize_old(init_method, *argv)
		self.send(init_method, *argv)
	end

=begin
	def []=(i, j, v)
		@rows[i][j] = v
	end
=end

	def clone
		super
	end

	def initialize_copy(orig)
		init_rows(orig.rows, true)
		self.wrap=(orig.wrap)
	end

	def set(m)
		0.upto(m.row_size - 1) do |i|
			0.upto(m.column_size - 1) do |j|
				self[i, j] = m[i, j]
			end
		end
		self.wrap = m.wrap
	end

	def wraplate(ijwrap = "")
		 "class << self
			  def [](i, j)
			    #{ijwrap}; @rows[i][j]
		    end

		    def []=(i, j, v)
		      #{ijwrap}; @rows[i][j] = v
		    end
		  end"
	end
	
	def wrap=(mode = :torus)
		case mode
		when :torus then eval(wraplate("i %= row_size; j %= column_size"))
		when :h_cylinder then eval(wraplate("i %= row_size"))
		when :v_cylinder then eval(wraplate("j %= column_size"))
		when :nil then eval(wraplate)
		end
		@wrap = mode
	end
	
	def max_len_column(j)		
		column_collect(j) {|x| x.to_s.length}.max
	end
	
	def cols_len
		(0...column_size).collect {|j| max_len_column(j)}
	end
	
	def to_s(mode = :pretty, len_col = 3)
		return super if empty?
		if mode == :pretty
			clen = cols_len
			to_a.collect {|r| mapcar(r, clen) {|x, l| format("%#{l}s ",x.to_s)} << "\n"}.join("")
		else
			i = 0; s = ""; cs = column_size
			each do |e|
				i = (i + 1) % cs
				s += format("%#{len_col}s ", e.to_s)
				s += "\n" if i == 0
			end
			s
	#		to_a.each {|r| r.each {|x| print format("%#{len_col}s ", x.to_s)}; print "\n"}
		end
	end

	def each
		@rows.each {|x| x.each {|e| yield(e)}}
		nil
	end
  
	def row!(i)
		if block_given?
			@rows[i].collect! {|e| yield(e)}
		else
			Vector.elements(@rows[i], false)
		end
	end

	def row_collect(row, &block)
		f = default_block(block)
		@rows[row].collect {|e| f.call(e)}
	end
	
	def column_collect(col, &block)
		f = default_block(block)	
		(0...row_size).collect {|r| f.call(self[r, col])}
	end
	
	alias :row_collect! :row!
	
	def column!(j)
		return (0...row_size).collect { |i| @rows[i][j] = yield(@rows[i][j])} if block_given?
	end

	alias :column_collect! :column!

	def column=(args)
		case args.size
		when 3 then range = args[2]
		when 4 then range = args[2]..args[3]
		else range = 0...row_size
		end
		range.each{|i| @rows[i][args[0]] = args[1][i]}
	end
	
	def row=(args)
		case args.size
		when 3 then range = args[2]
		when 4 then range = args[2]..args[3]
		else range = 0...column_size
		end
		row!(args[0]).slice=args[1], range
	end

	def norm(p = 2)
    Vector::Norm.sqnorm(self, p) ** (Float(1)/p)
	end

	def to_plot
		gplot = Tempfile.new('plot', Dir::tmpdir, false) # do not unlink
		gplot.puts(to_s)
		gplot.close
		gplot.path
	end
	
	def plot(back = true)
		Gnuplot.plot("splot '#{to_plot}' matrix with lines; pause -1", back)
	end

	def Matrix.mplot(*matrices)
		s = "splot "
		matrices.each {|x| s += "'#{x.to_plot}' matrix with lines,"}
		s = s[0..-2] + "; pause -1"
		Gnuplot.plot(s)
	end

	def empty?
		@rows.empty? if @rows
	end

# some new features
	def to_matrix(method, arg)
		a = self.send(method, arg).to_a
		(arg.is_a?(Range)) ? Matrix[*a] :	Matrix[a]
	end

	def row2matrix(r) # return the row/s of matrix as a matrix 
		to_matrix(:row, r)
	end

	def column2matrix(c) # return the colomn/s of matrix as a matrix
		to_matrix(:column, c).t
	end


  module LU
    def LU.tau(m, k) # calculate the  
      t = m.column2matrix(k)
      tk = t[k, 0]
      (0..k).each{|i| t[i, 0] = 0}
      return t if tk == 0
      (k+1...m.row_size).each{|i| t[i, 0] = t[i, 0].to_f / tk}
      t
    end

    def LU.M(m, k)
      i = Matrix.I(m.row_size)
      t = tau(m, k)
      e = i.row2matrix(k)
      i - t * e
    end

    def LU.gauss(m)
      a = m.clone
      (0..m.column_size-2).collect {|i| mi = M(a, i); a = mi * a; mi }
    end
  end 
  
	def U
		u = self.clone
		LU.gauss(self).each{|m| u = m * u}
		u
	end

	def L
		trans = LU.gauss(self)
		l = trans[0].inv
		(1...trans.size).each{|i| p trans[i].inv; l *= trans[i].inv}
		l
	end
end

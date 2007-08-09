require 'gnuplot'
require 'rational'
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
	alias :index :[]
	def [](i)
		case i
		when Range
			Vector[*to_a.slice(i)]
		else
			index(i)
		end	
	end

	def []=(i, v)
		case i
		when Range
			#i.each{|e| self[e] = v[e - i.begin]}
			(self.size..i.begin - 1).each{|e| self[e] = 0} # self.size must be in the first place because the size of self can be modified 
			[v.size, i.entries.size].min.times {|e| self[e + i.begin] = v[e]}
			(v.size + i.begin .. i.end).each {|e| self[e] = 0}
		else
			@elements[i]=v 
		end
	end

	class << self
		def add(*args)
			v = []
			args.each{|x| v += x.to_a}
			Vector[*v]
		end
	end

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
		map {|e| e.quo(c)}
	end

	def transpose
		Matrix[self.to_a]
	end
	
	alias :t :transpose
	
	# Computes the Householder vector (MC, Golub, p. 210, algorithm 5.1.1)
	def house
		s = self[1..length-1]
		sigma = s.inner_product(s)
		v = clone; v[0] = 1
		if sigma == 0
			beta = 0
		else
			mu = Math.sqrt(self[0] ** 2 + sigma)
			if self[0] <= 0
				v[0] = self[0] - mu
			else
				v[0] = - sigma.quo(self[0] + mu)
			end
			v2 = v[0] ** 2
			beta = 2 * v2.quo(sigma + v2)
			v /= v[0]
		end
		return v, beta
	end

	# Projection operator (http://en.wikipedia.org/wiki/Gram-Schmidt_process#The_Gram.E2.80.93Schmidt_process)
	def proj(v)
		vp = v.inner_product(self)
		vp = Float vp if vp.is_a?(Integer)
		self * (vp / inner_product(self))
	end

	def normalize
		self / self.norm
	end

	# Stabilized Gram-Schmidt process (http://en.wikipedia.org/wiki/Gram-Schmidt_process#Algorithm)
	def Vector.gram_schmidt(*vectors)
		v = vectors.clone
		for j in 0...v.size
			for i in 0..j-1
				v[j] -= v[i] * v[j].inner_product(v[i])
			end
			v[j] /= v[j].norm
		end
		v
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
		self.funcall(init_method, *argv)
	end

	alias :ids :[]
	def [](i, j)
		case i
		when Range 
			case j
			when Range
				Matrix[*i.collect{|l| self.row(l)[j].to_a}]
			else
				column(j)[i]	
			end
		else
			case j
			when Range
				row(i)[j]
			else
				ids(i, j)
			end
		end		
	end

	def []=(i, j, v)
		case i
		when Range
			if i.entries.size == 1
				self[i.begin, j] = (v.is_a?(Matrix) ? v.row(0) : v)
			else
				case j
				when Range
					if j.entries.size == 1
						self[i, j.begin] = (v.is_a?(Matrix) ? v.column(0) : v)
					else
						i.each{|l| self.row= l, v.row(l - i.begin), j}
					end
				else
					self.column= j, v, i	
				end
			end
		else
			case j
			when Range
				if j.entries.size == 1
					self[i, j.begin] = (v.is_a?(Vector) ? v[0] : v)
				else
					self.row= i, v, j
				end
			else
				@rows[i][j] = (v.is_a?(Vector) ? v[0] : v)

			end
		end		
	end	

	def clone
		super
	end

	def initialize_copy(orig)
		init_rows(orig.rows, true)
		self.wrap=(orig.wrap)
	end


	class << self
		def diag(*args)
			dsize = 0
			sizes = args.collect{|e| x = (e.is_a?(Matrix)) ? e.row_size : 1; dsize += x; x}
			m = Matrix.zero(dsize)
			count = 0

			sizes.size.times{|i| 
				range = count..(count+sizes[i]-1)
				m[range, range] = args[i]
				count += sizes[i]
			}
			m
		end
	end

	# Division by a scalar
	def quo(v)
		map {|e| e.quo(v)}
	end

	# quo seems always desirable
	alias :/ :quo

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
		c = args[0] # the column to be change
		v = args[1] #the values vector

	  case args.size
		when 3 then r = args[2] # the range 2..4
		when 4 then r = args[2]..args[3] #the range by borders
		else r = 0...row_size
		end
		#r.each{|e| self[e, c] = v[e - r.begin]}
		(self.row_size..r.begin - 1).each{|e| self[e, c] = 0}
		[v.size, r.entries.size].min.times{|e| self[e + r.begin, c] = v[e]}
		((v.size + r.begin)..r.end).each {|e| self[e, c] = 0}
	end
	
	def row=(args)
		case args.size
		when 3 then range = args[2]
		when 4 then range = args[2]..args[3]
		else range = 0...column_size
		end
		row!(args[0])[range]=args[1]
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

	def hQR #Householder QR
		h = []
		mat = self.clone
		m = row_size - 1
		n = column_size - 1
		(n+1).times{|j|
			v, beta = mat[j..m, j].house

			h[j] = Matrix.diag(Matrix.I(j), Matrix.I(m-j+1)- beta * (v * v.t))
			
			mat[j..m, j..n] = (Matrix.I(m-j+1) - beta * (v * v.t)) * mat[j..m, j..n]
			mat[(j+1)..m,j] = v[2..(m-j+1)] if j < m
		}
		h
	end

	def hBidiag #Householder Bidiagonalization
		u = []
		w = []
		mat = self.clone
		m = row_size - 1
		n = column_size - 1
		(n+1).times{|j|
			v, beta = mat[j..m,j].house
			mat[j..m, j..n] = (Matrix.I(m-j+1) - beta * (v * v.t)) * mat[j..m, j..n]
			mat[j+1..m, j] = v[1..(m-j)]

			# uj = [1 mat[j+1..m,j]] U_j's Householder vector
			uj = Vector.add(Vector[1], mat[j+1..m, j])
			u[j] = Matrix.diag(Matrix.I(j), Matrix.I(m-j+1)- beta * (uj * uj.t))
			
			if j <= n - 2
				v, beta = (mat[j, j+1..n]).house
				mat[j..m, j+1..n] = mat[j..m, j+1..n] * (Matrix.I(n-j) - beta * (v * v.t))
				mat[j, j+2..n] = v[1..n-j-1]
	
				vj = Vector.add(Vector[1], mat[j, j+2..n])
				w[j] = Matrix.diag(Matrix.I(j+1), Matrix.I(n-j)- beta * (vj * vj.t))
			end	
			}
		return u, w
	end
	
	# the bidiagonal matrix obtained with 
	# Householder Bidiagonalization algorithm
	def bidiagonal 
		u,v = self.hBidiag
		ub = Matrix.I(row_size)
		u.each{|x| ub *= x}
		vb = Matrix.I(column_size)
		v.each{|x| vb *= x}
		ub.t * self * vb
	end

	#householder Q = H_1 * H_2 * H_3 * ... * H_n
	def hQ 
		h = self.hQR
    q = h[0] 
    (1...h.size).each{|i| q *= h[i]} 
    q
  end

  # R = H_n * H_n-1 * ... * H_1 * A
  def hR
    h = self.hQR
    r = self.clone
    h.size.times{|i| r = h[i] * r}
    r
  end

	# Modified Gram Schmidt QR factorization (MC, Golub, p. 232)
	def gram_schmidt
		r = clone
		q = clone
		n = column_size
		m = row_size
		for k in 0...n
			r[k,k] = self[0...m, k].norm
			q[0...m, k] = self[0...m, k] / r[k, k]
			for j in (k+1)...n
				r[k, j] = q[0...m, k].t * self[0...m, j]
				self[0...m, j] -= q[0...m, k] * r[k, j]
			end
		end
	end

	def givens(a, b)
		if b = 0 
			c = 0; s = 0
		else
			if b.abs > a.abs
				theta = Float(-a)/b; s = 1/Math.sqrt(1+theta^2); c = s * theta
			else
				theta = Float(-b)/a; c = 1/Math.sqrt(1+theta^2); s = c * theta
			end
		end
	end

end

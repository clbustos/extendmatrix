require 'extendmatrix'

class Vector
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
			i.each{|e| self[e]=v[e - i.begin]}	
		else
			@elements[i]=v 
		end
	end
end

class Matrix
	def slice(lines, cols)
			return Matrix[*lines.collect{|l| row(l).slice(cols).to_a}] if lines.is_a?(Range) and cols.is_a?(Range)
			return column(cols).slice(lines) if lines.is_a?(Range) and cols.is_a?(Fixnum)
		  return row(lines).slice(cols) if lines.is_a?(Fixnum) and cols.is_a?(Range)
			return self[lines, cols] if lines.is_a?(Fixnum) and cols.is_a?(Fixnum)

	end

	def slice=(args)
		case args[1]
		when Range 
			case args[2]
			when Range
				args[1].each{|l| row = l, args[0].row(l - args[1].begin), args[2]}
			else
				column=args[2], args[0], args[1]	
			end
		else
			case args[2]
			when Range
				row=args[1], args[0],args[2]
			else
				self[args[1],args[2]] = args[0]
			end
		end		
	end

	alias :ids :[]
	def [](i, j)
		case i
		when Range 
			case j
			when Range
				Matrix[*i.collect{|l| self.row(l)[j]}
			else
				column(j)[i]	
			end
		else
			case j
			when Range
				row(i)[j]
			else
				self[i, j]
			end
		end		
	end

	def []=(i, j, v)
		case i
		when Range 
			case j
			when Range
				i.each{|l| self.row= l, v.row(l - i.begin), j}
			else
				self.column= j, v, i	
			end
		else
			case j
			when Range
				self.row= i, v, j
			else
				@rows[i][j] = v
			end
		end		
	end	

	def QR
		m = row_size
		n = column_size
		print "#{m} #{n}"
		m.times{|j|
			v, beta = slice(j..m, j).house
			p v
			p beta
			p m-j
			slice=(Matrix.I(m-j) - beta * (v * v.t)) * slice(j..m, j..n) , j..m, j..n
			slice= v.slice(2..(m-j+1)), j+1..m, j if j < m
		}
	end
end

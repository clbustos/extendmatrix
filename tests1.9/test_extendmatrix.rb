#ruby test.rb

require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'extendmatrix'

class TestVector < Test::Unit::TestCase
	@@v = Vector.[](1, 2, 3, 4)

	def test_collect
		v = @@v.clone
		assert_equal Vector.[](1, 4, 9, 16), v.collect!{|i| i * i}
		assert_equal Vector.[](3, 12, 27, 48), v.collect!{|i| 3 * i}
	end

	def test_each
		r = []
		@@v.each{|i| r << i+1}
		assert_equal [2, 3, 4, 5], r
	end

	def test_max
		assert_equal 4, @@v.max
	end

	def test_max
		assert_equal 1, @@v.min
	end

  def test_norm
		v = Vector[3, 4]
    assert_equal 5, v.norm
  end

  def test_p_norm1
    v = Vector.[](3, 4)
    assert_equal 7, v.norm(1)
  end

  def test_p_norm2
    v = Vector.[](3, 4)
    assert_equal 5, v.norm(2)
  end

  def test_p_norm3
    v = Vector.[](3, 4)
    assert_in_delta 4.497941, v.norm(3), 1.0e-5
  end

  def test_p_norm4
    v = Vector.[](3, 4)
    assert_in_delta 4.284572, v.norm(4), 1.0e-5
  end

  def test_setValue # []=
    v = @@v.clone
		v[3] = 10
    assert_equal Vector.[](1, 2, 3, 10), v
  end

  def test_norm_inf
    assert_equal 4, @@v.norm_inf
  end
		
end

class TestMatrix < Test::Unit::TestCase
	
	def test_set
		m = Matrix[[1, 2, 222], [2, 33, 4]]
		n = Matrix.new(2,3)
		n.set(m)
		assert_equal m, n
		m.wrap = :torus
		n.set(m)
		assert_equal :torus, n.wrap
	end

	def test_wrap
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		m.wrap=:torus
		assert_equal 1, m[2, 3]
		m.wrap=:h_cylinder
		assert_equal 1, m[2, 0]
		m.wrap=:v_cylinder
		assert_equal 1, m[0, 3]
  end

	def test_max_len_column
		m = Matrix[[1, 22, 3], [4, 5, 666666]]
		assert_equal 6, m.max_len_column(2)
  end

	#list of maximum lengths of columns
	def test_cols_len
		m = Matrix[[1, 2, 222], [2, 33, 4]]
		assert_equal [1, 2, 3], m.cols_len
		m = Matrix[[1, 12345, 222], [2, 3, 4]]
		assert_equal [1, 5, 3], m.cols_len
  end

	def test_each
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		r = []
		m.each{|x| r << x + 3}
		assert_equal [4, 5, 6, 7, 8, 9], r
  end

	def test_row!
		m = Matrix[[1, 2, 1], [2, 1, 2]]
		assert_equal [1, 4, 1], m.row!(0) {|x| x*x}
		m = Matrix[[1, 2, 1], [2, 1, 2]]
		assert_equal Vector[1, 2, 1], m.row!(0)
  end
 
 	def test_row_collect
		m = Matrix[[1, 2, 1], [2, 1, 2]]
		assert_equal [4, 1, 4], m.row_collect(1){|x| x*x}
  end

	def test_column_collect
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		assert_equal [7, 10], m.column_collect(1){|x| x+5}
		m = Matrix[[1, 2, 222], [2, 3, 4]]
		assert_equal [1, 4], m.column_collect(0){|x| x*x}
	end

	def test_row_collect!
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		m.row_collect!(1){|x| x*2}
		assert_equal Matrix[[1, 2, 3], [8, 10, 12]], m
  end

	def test_column_collect!
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		m.column_collect!(1){|x| x*2}
		assert_equal Matrix[[1, 4, 3], [4, 10, 6]], m
  end

	def test_norm
		m = Matrix[[1, 2, 1], [2, 1, 2]]
		assert_equal Math.sqrt(15), m.norm
  end

  def test_empty
		m = Matrix[[1, 2, 3], [4, 5, 6]]
		assert_equal false, m.empty?
		m = Matrix[]
		assert_equal true, m.empty?
  end

	def test_equal_in_delta
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, m.equal_in_delta?(m)
		mm = m.clone
		mm[0,0] += 2
		assert_equal false, m.equal_in_delta?(mm, 0.001)
		assert_equal true, m.equal_in_delta?(mm, 2)
	end

	def test_houseQR
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, m.equal_in_delta?(m.houseQ * m.houseR)
		q = Matrix[[0.0776, 0.8330, 0.5329,  0.1264], 
		 					 [0.3104, 0.4512, -0.8048, 0.2286], 
		  				 [0.5433, 0.0694, 0.0108, -0.8365], 
			 				 [0.7761, -0.3123, 0.2610, 0.4815]]
		assert_equal true, m.houseQ.equal_in_delta?(q, 0.0001)
	end

	def test_bidiagonalization	# MC, Golub, p252, Example 5.4.2
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		bidiag = Matrix[[12.884,	21.876,	0			],
										[0, 		 	2.246, 	-0.613],
										[0, 			0, 			0			],
										[0, 			0, 			0			]]
		assert_equal true, bidiag.equal_in_delta?(m.bidiagonal, 0.001)
	end

	def test_givens	
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, m.equal_in_delta?(m.givensQ * m.givensR, 0.001)
		assert_equal true, m.equal_in_delta?(Matrix::Givens.Q(m) * Matrix::Givens.R(m), 0.001)
	end

	def test_eigenvalQR
		m = Matrix.new(3, 3){1} + Matrix.diagonal(2, 2, 2)
		e = Matrix[[5, 0, 0],[0, 2, 0],[0, 0, 2]]
		assert_equal true, m.eigenvalQR.equal_in_delta?(e, 1.0e-5)
	end
end



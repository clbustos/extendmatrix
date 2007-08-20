#>ruby tests/test_xmatrix.rb

require 'test/unit' unless defined? $ZENTEST and $ZENTEST
require 'extendmatrix'

class TestVector < Test::Unit::TestCase
	@@v = Vector.[](1, 2, 3, 4)

	def test_setvalue
		v = @@v.clone
		v[1..2] = Vector[9, 9, 9, 9, 9]
		assert_equal Vector[1, 9, 9, 4], v
	end
	
	def test_concat
		assert_equal Vector[1, 2, 3], Vector.concat(Vector[1], Vector[2, 3])
		assert_equal Vector[1, 2, 3, 4, 5], Vector.concat(Vector[1], Vector[2, 3], Vector[4, 5])
	end

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

	def test_min
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
	
	def test_id
		m = Matrix.new(4, 3){|i, j| i * 3 + j}
		assert_equal 5, m[1, 2]
		assert_equal Vector[10, 11], m[3, 1..2] 
		assert_equal Matrix[[0, 1, 2], [3, 4, 5]], m[0..1, 0..2]
	end
	
	def test_id=
		m = Matrix.new(3, 3){|i, j| i * 3 + j}
		m[1, 2] = 9
		assert_equal Matrix[[0, 1, 2], [3, 4, 9], [6, 7, 8]], m
		m[1, 1..2] = Vector[8, 8]
		assert_equal Matrix[[0, 1, 2], [3, 8, 8], [6, 7, 8]], m
		m[0..1, 0..1] = Matrix[[0, 0, 0], [0, 0, 0]]
		assert_equal Matrix[[0, 0, 2], [0, 0, 8], [6, 7, 8]], m
	end

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

	def test_column=
		m = Matrix.new(3, 3){|i, j| i * 3 + j + 1}
		m.column= 1, Vector[1,1,1,1,1,1]
		assert_equal Matrix[[1, 1, 3],[4, 1, 6],[7, 1, 9]], m
		m.column= 2, Vector[9,9], 0..1
		assert_equal Matrix[[1, 1, 9],[4, 1, 9],[7, 1, 9]], m
	end

	def test_row=
		m = Matrix.new(3, 3){|i, j| i * 3 + j + 1}
		m.row= 1, Vector[1,1,1,1,1,1]
		assert_equal Matrix[[1, 2, 3],[1, 1, 1],[7, 8, 9]], m
		m.row= 2, Vector[9,9], 0..2
		assert_equal Matrix[[1, 2, 3],[1, 1, 1],[9, 9, 0]], m
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

	def test_row2matrix
		m = Matrix.new(4, 3){|i, j| i * 3 + j + 1}
		assert_equal Matrix[[4, 5, 6],[7, 8, 9]], m.row2matrix(1..2)
		assert_equal Matrix[[7, 8, 9]], m.row2matrix(2)
		assert_equal m, m.row2matrix(0..4)
	end

	def test_column2matrix
		m = Matrix.new(4, 3){|i, j| i * 3 + j + 1}
		assert_equal Matrix[[2], [5], [8], [11]], m.column2matrix(1)
	end

	def test_diag
		m1 = Matrix[[1]]
		m2 = Matrix[[2, 0], [0, 3]]
		m3 = Matrix[[4, 0, 0], [0, 5, 0], [0, 0, 6]]
		a1 = Matrix.new(6, 6){|i, j| i == j ? i + 1: 0}
		assert_equal a1, Matrix.diag(m1, m2, m3)
		assert_equal m2, Matrix.diag(m2)
		a2 = Matrix[[2, 0, 0, 0],
							 [0, 3, 0, 0],
							 [0, 0, 2, 0],
							 [0, 0, 0, 3]]
		assert_equal a2, Matrix.diag(m2, m2)
	end

	def test_equal_in_delta
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, Matrix.equal_in_delta?(m, m)
		mm = m.clone
		mm[0,0] += 2
		assert_equal false, Matrix.equal_in_delta?(m, mm, 0.001)
		assert_equal true, Matrix.equal_in_delta?(m, mm, 2)
	end

	def test_diag_in_delta
		assert_equal false, Matrix.diag_in_delta?(Matrix.I(5), Matrix.new(4, 4){|i, j| i + j})
		m  = Matrix.new(5, 5){|i, j| i == j ? 1 + 0.001 * (i+1) : i + j}
		assert_equal true, Matrix.diag_in_delta?(Matrix.I(5), m, 0.01)
	end

	def test_LU
		m = Matrix[[1, 4, 7],
							 [2, 5, 8],
							 [3, 6, 10]]
		l = Matrix[[1, 0, 0],[2, 1, 0],[3, 2, 1]]
		assert_equal l, m.L
		u = Matrix[[1, 4, 7],[0, -3, -6],[0, 0, 1]]
		assert_equal u, m.U
	end

	def test_L 
	# e.g.: MC, Golub, 3.2 LU factorization, pg 94
		m = Matrix[[3, 5],
							 [6, 7]]
		l = Matrix[[1, 0],
							 [2, 1]]
		assert_equal l, m.L
	end

	def test_U
	# e.g.: MC, Golub, 3.2 LU factorization, pg 94
		m = Matrix[[3, 5],
							 [6, 7]]
		u = Matrix[[3, 5],
							 [0, -3]]
		assert_equal u, m.U
	
	end

	def test_houseQR
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, Matrix.equal_in_delta?(m, m.houseQ * m.houseR)
		q = Matrix[[0.0776, 0.8330, 0.5329,  0.1264], 
		 					 [0.3104, 0.4512, -0.8048, 0.2286], 
		  				 [0.5433, 0.0694, 0.0108, -0.8365], 
			 				 [0.7761, -0.3123, 0.2610, 0.4815]]
		assert_equal true, Matrix.equal_in_delta?(m.houseQ, q, 0.0001)
	end

	def test_houseR
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		r = Matrix[[12.88409, 14.59162, 16.29916], 
							 [       0,  1.04131, 2.082630],
							 [       0,        0,        0], 
							 [       0,        0,        0]]
		assert_equal true, Matrix.equal_in_delta?(r, m.houseR, 1.0e-5)
	end

	def test_bidiagonalization	# MC, Golub, p252, Example 5.4.2
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		bidiag = Matrix[[12.884,	21.876,	0			],
										[0, 		 	2.246, 	-0.613],
										[0, 			0, 			0			],
										[0, 			0, 			0			]]
		assert_equal true, Matrix.equal_in_delta?(bidiag, m.bidiagonal, 0.001)
	end

	def test_gram_schmidt
		m = Matrix[[1,     1],
							 [0.001, 0],
							 [0, 0.001]]
		gsQ = Matrix[[    1,         0],
								 [0.001, -0.707107],
								 [    0,  0.707100]]
		assert_equal true, Matrix.equal_in_delta?(gsQ, m.gram_schmidt[0], 0.001)
		assert_equal true, Matrix.equal_in_delta?(m,m.gram_schmidt[0] * m.gram_schmidt[1], 1.0e-5)
	end
	
	def test_givens	
		m = Matrix.new(4, 3){|i, j| i * 3 + j +1}
		assert_equal true, Matrix.equal_in_delta?(m, m.givensQ * m.givensR, 0.001)
	end

	def test_hessenbergQR
		hess = Matrix[[1, 2, 1, 2, 1], 
									[1, 3, 2, 3, 4],
									[0, 2, 4, 3, 5],
									[0, 0, 1, 4, 3],
									[0, 0, 0, 6, 1]]
		hessR = hess.hessenbergR
		r = Matrix[[1.41421,  3.53553,  2.12132,  3.53553,  3.53553],
							 [      0, -2.12132, -4.00693, -3.06412, -5.42115], 
							 [      0,        0, -1.20185, -3.51310, -2.31125], 
							 [      0,        0,        0, -6.30628, -1.54912], 
							 [      0,        0,        0,        0,  1.53929]]

		assert_equal true, Matrix.equal_in_delta?(r, hessR, 1.0e-5)
		assert_equal true, Matrix.equal_in_delta?(hessR, hess.hessenbergQ.t * hess, 1.0e-5)
	end

	def test_hessenberg_form
		m = Matrix[[1, 5, 7],[3, 0, 6],[4, 3, 1]]
		h = Matrix[[1, 8.6, -0.2],[5, 4.96, -0.72],[0, 2.28, -3.96]]
		assert_equal true, Matrix.equal_in_delta?(h, m.hessenberg_form_H, 0.001)
	end

	def test_realSchur
		m = Matrix.new(3, 3){1} + Matrix.diagonal(2, 2, 2)
		e = Matrix[[5, 0, 0],[0, 2, 0],[0, 0, 2]]
		assert_equal true, Matrix.diag_in_delta?(m.realSchur, e, 1.0e-5)
	end

	def test_cJacobi
		m = Matrix[[3, 1, 1],[1, 3, 1],[1, 1, 3]]
		v = Matrix[[2, 0, 0],[0, 5, 0],[0, 0, 2]]
		assert_equal true, Matrix.diag_in_delta?(v, m.cJacobiA, 0.01)
		a = Matrix[[1, 1, 1, 4],
							 [1, 1, 0, 5],
							 [1, 0, 1, 4],
							 [4, 5, 4, 1]]
		e = Matrix[[-0.26828, 0, 0, 0], [0, -5.97550, 0, 0], [0, 0, 1.01373, 0], [0, 0, 0, 9.23004]]
		assert_equal true, Matrix.diag_in_delta?(e, a.cJacobiA, 1.0e-5)
	end

=begin
	def test_eigenvaluesJacobi
		a = Matrix[[1, 1, 1, 4],
							 [1, 1, 0, 5],
							 [1, 0, 1, 4],
							 [4, 5, 4, 1]]
		eigenvalues = [-0.268280385530705, -5.97550058143538, 1.01373431639199, 9.2300466505741]
		p a.eigenvaluesJacobi

		assert_equal eigenvalues,  a.eigenvaluesJacobi
=end
end


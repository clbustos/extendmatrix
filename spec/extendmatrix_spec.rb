$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rspec'
require 'rspec/core/rake_task'

require 'extendmatrix'

describe "Vector class extension:" do
  before do
    @v = Vector.[](1, 2, 3, 4)
  end
  it "[] with range returns correct values" do
  @v[1..2]==Vector[2,3]
  end
  it "[]= should change only specified range" do
    @v[1..2] = Vector[9, 9, 9, 9, 9]
    @v.should == Vector[1, 9, 9, 4]
  end
  
  it "magnitude methods returns vector length" do
    @v.magnitude.should==Math::sqrt(30)
  end
  it "normalize methods returns the vector normalized" do
    mag=Math::sqrt(30)
    @v.normalize.should==@v.quo(mag)
  end
  it "Vector.concat method should concat vectors" do
    Vector.concat(Vector[1], Vector[2, 3]).should == Vector[1, 2, 3]
    Vector.concat(Vector[1], Vector[2, 3], Vector[4, 5]).should ==  Vector[1, 2, 3, 4, 5]
  end
  it "collect method returns collected vector and doesn't change original" do
  @v.collect{|i| i*i}.should== Vector.[](1,4,9,16)
  @v.should==Vector[1,2,3,4]
  end
  it "collect! method should change vector" do
    @v.collect!{|i| i * i}
    @v.should == Vector.[](1, 4, 9, 16)
    @v.collect!{|i| 3 * i}
    @v.should == Vector.[](3, 12, 27, 48)
  end

  it "each method" do
    r = []
    @v.each{|i| r << i+1}
    r.should == [2, 3, 4, 5]
  end

  it "max method should return max element" do
    @v.max.should == 4
  end

  it "min method should return min element" do
    @v.min.should == 1
  end

  it "norm method returns correct norm" do
    v = Vector.[](3, 4)
    v.norm.should == 5
  end

  it "method p_norm(1)" do
    v = Vector.[](3, 4)
    v.norm(1).should == 7
  end

  it "method p_norm(2)" do
    v = Vector.[](3, 4)
    v.norm(2).should == 5
  end

  it "method p_norm(3)" do
    v = Vector.[](3, 4)
    v.norm(3).should > 4.49
    v.norm(3).should < 4.50
  end

  it "method p_norm(4)" do
    v = Vector.[](3, 4)
    v.norm(4).should > 4.28
    v.norm(4).should < 4.29
  end

  it "[]= method should change specific value" do
    @v[3] = 10
    @v.should == Vector.[](1, 2, 3, 10)
  end

  it "norm_inf" do
    @v.norm_inf.should == 4
  end
  it "sum method returns the sum of elements" do
    @v.sum.should==10
  end
  
  it "allows for multiple assignment" do
    a, b, c, d = @v
    [a, b, c, d].should == [1, 2, 3, 4]
  end
end

describe "Matrix class extension:" do
  before do
    @m = Matrix[[1, 2, 222], [2, 33, 4]]
  end
  it "to_s method should return something" do
    @m.to_s.size.should_not == 0
  end
  it "[] method" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j}
    m[1, 2].should == 5
    m[3, 1..2].should ==  Vector[10, 11]
    m[0..1, 0..2].should == Matrix[[0, 1, 2], [3, 4, 5]]
  end
  it "row_sum method" do
	  @m.row_sum[0].should==225
  end
  it "column_sum method" do
	  @m.column_sum[0].should==3
  end
  it "total_sum method" do
	  @m.total_sum.should==264
  end
  
  it "[]= method" do
    m = Matrix.build(3, 3){|i, j| i * 3 + j}
    m[1, 2] = 9
    m.should == Matrix[[0, 1, 2], [3, 4, 9], [6, 7, 8]]
    m[1, 1..2] = Vector[8, 8]
    m.should == Matrix[[0, 1, 2], [3, 8, 8], [6, 7, 8]]
    m[0..1, 0..1] = Matrix[[0, 0, 0], [0, 0, 0]]
    m.should == Matrix[[0, 0, 2], [0, 0, 8], [6, 7, 8]]
  end

  it "set method" do
    n = Matrix.build(2, 3)
    n.set(@m)
    n.should == @m
  end

  it "set method and wrap value" do
    @m.wrap = :torus
    n = Matrix.build(2, 3)
    n.set(@m)
    n.wrap.should == :torus
  end

  it "wrap method" do
    @m.wrap=:torus
    @m[2, 3].should == 1
    @m.wrap=:h_cylinder
    @m[2, 0].should == 1
    @m.wrap=:v_cylinder
    @m[0, 3].should == 1
  end

  it "maximum length of a column" do
    @m.max_len_column(1).should == 2
  end

  it "list of maximum lengths of columns" do
    @m.cols_len.should == [1, 2, 3]
  end

  it "matrix each method" do
    r = []
    @m.each{|x| r << x + 3}
    r.should == [4, 5, 225, 5, 36, 7]

    s = 0
    @m.each{|x| s += x}
    s.should == 264
  end

  it "row! method" do
    @m.row!(0){|x| x+x}.should == [2, 4, 444]
    @m.should == Matrix[[2, 4, 444], [2, 33, 4]]
  end

  it "row_collect method" do
    @m.row_collect(1){|x| x+10}.should == [12, 43, 14]
  end

  it "column_collect method" do
    @m.column_collect(0){|x| x*3}.should == [3, 6]
  end

  it "row_collect! method, identicaly with row!" do
    @m.row_collect!(0){|x| x+x}.should == [2, 4, 444]
    @m.should == Matrix[[2, 4, 444], [2, 33, 4]]
  end

  it "column_collect! method" do
    @m.column_collect!(2){|x| x+10}.should == [232, 14]
    @m.should == Matrix[[1, 2, 232], [2, 33, 14]]
  end

  it "column= " do
    m = Matrix.build(3, 3){|i, j| i * 3 + j + 1}
    m.column= 1, Vector[1,1,1,1,1,1]
    m.should == Matrix[[1, 1, 3],[4, 1, 6],[7, 1, 9]]
    m.column= 2, Vector[9,9], 0..1
    m.should == Matrix[[1, 1, 9],[4, 1, 9],[7, 1, 9]]
  end

  it "row= " do
    m = Matrix.build(3, 3){|i, j| i * 3 + j + 1}
    m.row= 1, Vector[1,1,1,1,1,1]
    m.should == Matrix[[1, 2, 3],[1, 1, 1],[7, 8, 9]]
    m.row= 2, Vector[9,9], 0..2
    m.should == Matrix[[1, 2, 3],[1, 1, 1],[9, 9, 0]]
  end

  it "norm of a matrix" do
    m = Matrix[[1, 2, 3], [1, 2, 3]]
    m.norm.should == Math.sqrt(28)
  end

  it "test empty matrix" do
    @m.empty?.should == false
    n = Matrix[]
    n.empty?.should == true
  end

  it "row2matrix" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j + 1}
    
    m.row2matrix(1..2).should == Matrix[[4, 5, 6],[7, 8, 9]]
    m.row2matrix(2).should == Matrix[[7, 8, 9]]
    m.row2matrix(0..4).should == m
  end

  it "column2matrix" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j + 1}
    m.column2matrix(1).should == Matrix[[2], [5], [8], [11]]
    m.column2matrix(1..1).should == Matrix[[2], [5], [8], [11]]

    m.column2matrix(1..2).should == Matrix[[2,3], [5,6], [8,9], [11,12]]
    
  end

  it "diag" do
    m1 = Matrix[[1]]
    m2 = Matrix[[2, 0], [0, 3]]
    m3 = Matrix[[4, 0, 0], [0, 5, 0], [0, 0, 6]]
    a1 = Matrix.build(6, 6){|i, j| i == j ? i + 1: 0}
    Matrix.diag(m1, m2, m3).should == a1
    Matrix.diag(m2).should == m2
    a2 = Matrix[[2, 0, 0, 0],
      [0, 3, 0, 0],
      [0, 0, 2, 0],
    [0, 0, 0, 3]]
    Matrix.diag(m2, m2).should == a2
  end
  it "dup" do
    m=Matrix.build(4, 3){|i, j| i * 3 + j +1}
    mm=m.dup
    mm.object_id.should_not==m.object_id
    m[0,0]=10
    mm[0,0].should_not==m[0,0]
  end
  it "equal_in_delta" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    Matrix.equal_in_delta?(m, m).should == true
    mm = m.clone
    mm[0,0] += 2
    Matrix.equal_in_delta?(m, mm, 0.001).should == false
    Matrix.equal_in_delta?(m, mm, 2).should == true
  end

  it "diag_in_delta" do
    Matrix.diag_in_delta?(Matrix.I(5), Matrix.build(4, 4){|i, j| i + j}).should == false
    m  = Matrix.build(5, 5){|i, j| i == j ? 1 + 0.001 * (i+1) : i + j}
    Matrix.diag_in_delta?(Matrix.I(5), m, 0.01).should == true
  end
  
  
  it "e_mult method" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    n = Matrix.build(4, 3){|i, j| i * 2 + j +2}
    m.e_mult(n).should==Matrix.build(4,3){|i,j| (i*3+j+1)*(i*2+j+2)}
  end
  it "e_mult method" do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    n = Matrix.build(4, 3){|i, j| i * 2 + j +2}
    m.e_quo(n).should==Matrix.build(4,3){|i,j| (i*3+j+1).quo(i*2+j+2)}
  end
  it "mssq method" do
    m = Matrix[[1,2,3],[4,5,6],[7,8,9]]
    m.mssq.should==(1..9).each.inject(0) {|ac,v| ac+v**2}
  end
  it "eigen" do
    m=Matrix[[0.95,0.95,0.01,0.01],[0.95,0.95,0.01,0.01],[0.01, 0.01,0.95,0.95], [0.01, 0.01, 0.95, 0.95]]
    eigenvalues=[1.92,1.88,0.0,0.0]
    eigen=m.eigen
    eigen[:eigenvalues].each_with_index do |v,i|
      v.should be_within(0.01).of(eigenvalues[i])
    end
    eigenvectors=Matrix[[0.5, 0.5, 0.0, 0.707106781186547], [0.5, 0.5, 0.0, -0.707106781186547], [0.5, -0.5, 0.707106781186547, 0.0], [0.5, -0.5, -0.707106781186547, 0.0]]
    expect(Matrix.equal_in_delta?(eigen[:eigenvectors], eigenvectors)).to be(true)
  end
  it "eigenpairs" do
    m=Matrix[[0.95,0.95,0.01,0.01],[0.95,0.95,0.01,0.01],[0.01, 0.01,0.95,0.95], [0.01, 0.01, 0.95, 0.95]]
    eigenpairs=[[1.92, Vector[0.5, 0.5, 0.5, 0.5]], [1.88, Vector[0.5, 0.5, -0.5, -0.5]], [0.0, Vector[0.0, 0.0, 0.707, -0.707]], [0.0, Vector[0.707, -0.707, 0.0, 0.0]]]
    observed=m.eigenpairs
    eigenpairs.each_with_index do |v,i|
      observed[i][0].should be_within(0.001).of(v[0])
      observed[i][1].each_with_index {|vv,ii|
        vv.should be_within(0.001).of(v[1][ii])
      }
      
    end
  end
  it "sqrt" do
    m=Matrix[[1,4,9],[16,25,36]]
    m.sqrt.should==Matrix[[1,2,3],[4,5,6]]
  end
  it "sscp" do
    m=Matrix[[1,4,9],[16,25,36]]
    m.sscp.should== m.t*m
  end
  it "diagonal" do
    m=Matrix.diag(1,4,5,6,7)
    m.diagonal.should==[1,4,5,6,7]
    m=Matrix[[1,2,3],[4,5,6],[7,8,9],[10,11,12]]
    m.diagonal.should==[1,5,9]  
  end
  it "LU " do
    m = Matrix[[1, 4, 7],
      [2, 5, 8],
    [3, 6, 10]]
    l = Matrix[[1, 0, 0],[2, 1, 0],[3, 2, 1]]
    m.L.should == l
    u = Matrix[[1, 4, 7],[0, -3, -6],[0, 0, 1]]
    m.U.should == u
  end

  it "L " do
    # e.g.: MC, Golub, 3.2 LU factorization, pg 94
    m = Matrix[[3, 5],
    [6, 7]]
    l = Matrix[[1, 0],
    [2, 1]]
    m.L.should == l
  end

  it "U " do
    # e.g.: MC, Golub, 3.2 LU factorization, pg 94
    m = Matrix[[3, 5],
    [6, 7]]
    u = Matrix[[3, 5],
    [0, -3]]
    m.U.should == u
  end

  it "houseQR " do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    Matrix.equal_in_delta?(m, m.houseQ * m.houseR).should == true
    q = Matrix[[0.0776, 0.8330, 0.5329,  0.1264],
      [0.3104, 0.4512, -0.8048, 0.2286],
      [0.5433, 0.0694, 0.0108, -0.8365],
    [0.7761, -0.3123, 0.2610, 0.4815]]
    Matrix.equal_in_delta?(m.houseQ, q, 0.0001).should == true
  end

  it "houseR " do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    r = Matrix[[12.88409, 14.59162, 16.29916],
      [       0,  1.04131, 2.082630],
      [       0,        0,        0],
    [       0,        0,        0]]
    Matrix.equal_in_delta?(r, m.houseR, 1.0e-5).should == true
  end

  it "bidiagonalization" do
    # MC, Golub, p252, Example 5.4.2
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    bidiag = Matrix[[12.884,  21.876, 0     ],
      [0,       2.246,  -0.613],
      [0,       0,      0     ],
    [0,       0,      0     ]]
    Matrix.equal_in_delta?(bidiag, m.bidiagonal, 0.001).should == true
  end

  it "gram_schmidt" do
    m = Matrix[[1,     1],
      [0.001, 0],
    [0, 0.001]]
    gsQ = Matrix[[    1,         0],
      [0.001, -0.707107],
    [    0,  0.707100]]
    Matrix.equal_in_delta?(gsQ, m.gram_schmidt[0], 0.001).should == true
    Matrix.equal_in_delta?(m,m.gram_schmidt[0] * m.gram_schmidt[1], 1.0e-5).should == true
  end

  it "givens " do
    m = Matrix.build(4, 3){|i, j| i * 3 + j +1}
    Matrix.equal_in_delta?(m, m.givensQ * m.givensR, 0.001).should == true
  end

  it "hessenbergQR " do
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

    Matrix.equal_in_delta?(r, hessR, 1.0e-5).should == true
    Matrix.equal_in_delta?(hessR, hess.hessenbergQ.t * hess, 1.0e-5).should == true
  end

  it "hessenberg_form " do
    m = Matrix[[1, 5, 7],[3, 0, 6],[4, 3, 1]]
    h = Matrix[[1, 8.6, -0.2],[5, 4.96, -0.72],[0, 2.28, -3.96]]
    Matrix.equal_in_delta?(h, m.hessenberg_form_H, 0.001).should == true
  end

  it "realSchur" do
    m = Matrix.build(3, 3){1} + Matrix.diagonal(2, 2, 2)
    e = Matrix[[5, 0, 0],[0, 2, 0],[0, 0, 2]]
    Matrix.diag_in_delta?(m.realSchur, e, 1.0e-5).should == true
  end

  it "Classic Jacobi algorithm" do
    m = Matrix[[3, 1, 1],[1, 3, 1],[1, 1, 3]]
    v = Matrix[[2, 0, 0],[0, 5, 0],[0, 0, 2]]
    Matrix.diag_in_delta?(v, m.cJacobiA, 0.01).should == true
    a = Matrix[[1, 1, 1, 4],
      [1, 1, 0, 5],
      [1, 0, 1, 4],
    [4, 5, 4, 1]]
    e = Matrix[[-0.26828, 0, 0, 0], [0, -5.97550, 0, 0], [0, 0, 1.01373, 0], [0, 0, 0, 9.23004]]
    Matrix.diag_in_delta?(e, a.cJacobiA, 1.0e-5).should == true
  end
  
  it "allows for multiple assignment" do
    a, b = @m
    [a, b].should == [[1, 2, 222], [2, 33, 4]]
  end
end


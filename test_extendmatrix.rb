require 'extendmatrix'

context "Vector class extension:" do
	setup do
		@v = Vector.[](1, 2, 3, 4)	
	end
	specify "collect function" do
		@v.collect!{|i| i * i}.should == Vector.[](1, 4, 9, 16)
		@v.collect!{|i| 3 * i}.should == Vector.[](3, 12, 27, 48)
	end

  specify "each function" do
		r = []
		@v.each{|i| r << i+1}
		r.should == [2, 3, 4, 5]
	end

  specify "max element" do
		@v.max.should == 4
	end

  specify "norm function" do
		v = Vector.[](3, 4)
		v.norm.should == 5
	end

  specify "function p_norm(1)" do
		v = Vector.[](3, 4)
		v.norm(1).should == 7
	end

  specify "function p_norm(2)" do
		v = Vector.[](3, 4)
		v.norm(2).should == 5
	end

	
  specify "function p_norm(3)" do
		v = Vector.[](3, 4)
		v.norm(3).should > 4.49
		v.norm(3).should < 4.50
	end
	
  specify "function p_norm(4)" do
		v = Vector.[](3, 4)
		v.norm(4).should > 4.28
		v.norm(4).should < 4.29
	end
	
	specify "[]= test" do
		@v[3] = 10
		@v.should == Vector.[](1, 2, 3, 10)
	end

	specify "norm_inf" do
		@v.norm_inf.should == 4
	end
end

context "Matrix class extension:" do
	setup do
		@m = Matrix[[1, 2, 222], [2, 33, 4]]	
	end

	specify "set function" do
		n = Matrix.new(2, 3)
		n.set(@m)
		n.should == @m
	end

	specify "set function and wrap value" do
		@m.wrap = :torus
		n = Matrix.new(2, 3)
		n.set(@m)
		n.wrap.should == :torus
	end

	specify "wrap function" do
		@m.wrap=:torus
		@m[2, 3].should == 1
		@m.wrap=:h_cylinder
		@m[2, 0].should == 1
		@m.wrap=:v_cylinder
		@m[0, 3].should == 1
	end

	specify "maximum length of a column" do
		@m.max_len_column(1).should == 2
	end

	specify "list of aximum lengths of columns" do
		@m.cols_len.should == [1, 2, 3]
	end

	specify "matrix each function" do
		r = []
		@m.each{|x| r << x + 3}
		r.should == [4, 5, 225, 5, 36, 7]

		s = 0
		@m.each{|x| s += x}
		s.should == 264
	end

	specify "row! functionality" do
		@m.row!(0){|x| x+x}.should == [2, 4, 444]
		@m.should == Matrix[[2, 4, 444], [2, 33, 4]]
	end

	specify "row_collect function" do
		@m.row_collect(1){|x| x+10}.should == [12, 43, 14]
	end

	specify "column_collect function" do
		@m.column_collect(0){|x| x*3}.should == [3, 6]
	end

	specify "row_collect! function, identicaly with row!" do
		@m.row_collect!(0){|x| x+x}.should == [2, 4, 444]
		@m.should == Matrix[[2, 4, 444], [2, 33, 4]]
	end

	specify "column_collect! function" do
		@m.column_collect!(2){|x| x+10}.should == [232, 14]
		@m.should == Matrix[[1, 2, 232], [2, 33, 14]]
	end

	specify "norm of a matrix" do
		m = Matrix[[1, 2, 3], [1, 2, 3]]
		m.norm.should == Math.sqrt(28)
	end

	specify "test empty matrix" do
		@m.empty?.should == false 
		n = Matrix[]
		n.empty?.should == true
	end
end

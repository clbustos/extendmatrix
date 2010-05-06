= extendmatrix

* http://github.com/clbustos/extendmatrix

== DESCRIPTION:

The project consists of some enhancements to the Ruby "Matrix" module and includes: LU and QR (Householder, Givens, Gram Schmidt, Hessenberg) decompositions, bidiagonalization, eigenvalue and eigenvector calculations.
Include some aditional code to obtains marginal for rows and columns.

Original code from http://rubyforge.org/projects/matrix/

Work done by Cosmin Bonchis as a Google Summer of Code 2007 project for Ruby Central Inc.

== SYNOPSIS:

  require 'matrix_extensions'
  m = Matrix.new(4, 3){|i, j| i * 3 + j}
  m[1, 2].should == 5
  m[3, 1..2].should ==  Vector[10, 11]
  m[0..1, 0..2].should == Matrix[[0, 1, 2], [3, 4, 5]]

== REQUIREMENTS:

* Only Ruby

== INSTALL:

* sudo gem install matrix-extensions

== LICENSE:

One of http://www.opensource.org/licenses/

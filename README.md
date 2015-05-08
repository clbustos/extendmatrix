# extendmatrix

* http://github.com/SciRuby/extendmatrix

## DESCRIPTION:

The project consists of some enhancements to the Ruby "Matrix" module and includes: LU and QR (Householder, Givens, Gram Schmidt, Hessenberg) decompositions, bidiagonalization, eigenvalue and eigenvector calculations.
Include some aditional code to obtains marginal for rows and columns.

Original code done by Cosmin Bonchis as a Google Summer of Code 2007 project for Ruby Central Inc.

Gem, github repository and current version mantained by Claudio Bustos and the Ruby Science Foundation.

## SYNOPSIS:

  require 'extendmatrix'
  v = Vector[1, 2, 3, 4]
  
  v.magnitude # => 5.47722557505166
  
  v.normalize # => Vector[0.182574185835055, 0.365148371670111, 0.547722557505166, 0.730296743340221]
  
  # Backport from Ruby 1.9.2+
  m = Matrix.build(4, 3){|i, j| i * 3 + j}
  # => Matrix[[0, 1, 2], [3, 4, 5], [6, 7, 8], [9, 10, 11]]
  
  # You could modify the matrix
  m = Matrix.I(3)
  m[0,1]=m[1,0]=0.5
  m[0,2]=m[2,0]=0.7
  m[1,2]=m[2,1]=0.9
  m           # => Matrix[[1, 0.5, 0.7], [0.5, 1, 0.9], [0.7, 0.9, 1]]
  
  # Eigenvalues and EigenVectors. PCA at sight :)
  
  m.eigenvaluesJacobi => Vector[0.523942339006665, 0.0632833995384682, 2.41277426145487]
  m.cJacobiV
  # => Matrix[[0.818814082563014, 0.249617871497675, 0.516947208547894], [-0.550168858227442, 0.598307531004925, 0.58253096551128], [-0.163883268313767, -0.761392813580323, 0.62723461144538]]

## REQUIREMENTS:

* Ruby > 1.9.3

## INSTALL:

* sudo gem install extendmatrix

## LICENSE:

Copyright [2007] Cosmin Bonchis
Copyright [2010] Claudio Bustos
Copyright [2015] Ruby Science Foundation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
this file except in compliance with the License. You may obtain a copy of the 
License at 

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed 
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
CONDITIONS OF ANY KIND, either express or implied. See the License for the 
specific language governing permissions and limitations under the License. 

See LICENSE.txt for more details
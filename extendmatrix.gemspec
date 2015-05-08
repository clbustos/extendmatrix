# coding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)

require 'version.rb'

DESCRIPTION = <<MSG
The project consists of some enhancements to the Ruby "Matrix" module and 
includes: LU and QR (Householder, Givens, Gram Schmidt, Hessenberg) 
decompositions, bidiagonalization, eigenvalue and eigenvector calculations.

Includes some aditional code to obtains marginal for rows and columns.
MSG

Gem::Specification.new do |spec|
  spec.name          = 'extendmatrix'
  spec.version       = Matrix::EXTENSION_VERSION
  spec.authors       = ['Cosmin Bonchis', 'Claudio Bustos', 'Sameer Deshmukh']
  spec.email         = ['sameer.deshmukh93@gmail.com']
  spec.summary       = %q{Enhancements to ruby "Matrix" and "Vector" modules}
  spec.description   = DESCRIPTION
  spec.homepage      = "http://github.com/SciRuby/extendmatrix"
  spec.license       = 'Apache v2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
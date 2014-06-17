# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'propro/version'

Gem::Specification.new do |spec|
  spec.name          = 'propro'
  spec.version       = Propro::VERSION
  spec.authors       = ['Carsten Nielsen']
  spec.email         = ['heycarsten@gmail.com']
  spec.summary       = 'A standalone server provisioning tool'
  spec.description   = 'Propro is a tool for provisioning remote servers.'
  spec.homepage      = 'http://github.com/heycarsten/propro'
  spec.license       = 'GNU v2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^test\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'thor',    '~> 0.19'
  spec.add_dependency 'net-scp', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end

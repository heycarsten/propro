# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'propro/version'

Gem::Specification.new do |spec|
  spec.name          = 'propro'
  spec.version       = Propro::VERSION
  spec.authors       = ['Carsten Nielsen']
  spec.email         = ['heycarsten@gmail.com']
  spec.summary       = 'Provision servers with Bash'
  spec.description   = ''
  spec.homepage      = 'http://heycarsten.com/propro'
  spec.license       = 'GNU v2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor',    '~> 0.18'
  spec.add_dependency 'net-scp', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end

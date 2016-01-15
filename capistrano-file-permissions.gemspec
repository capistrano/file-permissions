# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-file-permissions'
  spec.version       = '1.0.0'
  spec.authors       = ['Peter Mitchell']
  spec.email         = ['peterjmit@gmail.com']
  spec.description   = %q{File permissions management for Capistrano 3.x}
  spec.summary       = %q{File permissions management for Capistrano 3.x}
  spec.homepage      = 'https://github.com/capistrano/file-permissions'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.0'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque_sliding_window/version'

Gem::Specification.new do |spec|
  spec.name          = "resque_sliding_window"
  spec.version       = ResqueSlidingWindow::VERSION
  spec.authors       = ["Jon Phenow"]
  spec.email         = ["j.phenow@gmail.com"]
  spec.description   = %q{Sliding Window unique-job workflow for Resque jobs}
  spec.summary       = %q{Sliding Window unique-job workflow for Resque jobs}
  spec.homepage      = "https://github.com/sportngin/resque_sliding_window"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'resque', '~> 1.21'
  spec.add_dependency 'resque-scheduler', '~> 4.3'
end

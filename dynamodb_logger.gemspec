# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dynamodb_logger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mike Challis"]
  gem.email         = ["mike.challis@matchbin.com"]
  gem.description   = %q{Uses a standard ruby Logger object to log to Amazon's DynamoDB}
  gem.summary       = %q{Use a standard ruby Logger to log to Amazon's DynamoDB}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dynamodb_logger"
  gem.require_paths = ["lib"]
  gem.version       = DynamodbLogger::VERSION

  gem.add_runtime_dependency "fog", '~>1.7.0'
  gem.add_development_dependency 'rspec'
end

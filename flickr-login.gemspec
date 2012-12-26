# encoding: utf-8
Gem::Specification.new do |gem|
  gem.name          = "flickr-login"
  gem.authors       = ["Janko Marohnić"]
  gem.email         = ["janko.marohnic@gmail.com"]
  gem.description   = %q{This is a Rack endpoint that provides Flickr authentication. Basically it is a lightweight alternative to the "omniauth-flickr" gem.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/janko-m/flickr-login"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = "0.0.3"

  gem.add_dependency "oauth"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rescuetime/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ruby-rescuetime"
  s.version     = RubyRescuetime::VERSION
  s.authors     = ["Patrick Helm"]
  s.email       = ["deradon87@gmail.com"]
  s.homepage    = "https://github.com/Deradon/Ruby-Rescuetime"
  s.summary     = "ruby port of RescueTimeLinuxUploader"
  s.description = "Upload your data to: https://www.rescuetime.com"

  s.executables = ["ruby-rescuetime"]
  s.files = Dir["{bin,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #s.add_dependency "rails", "~> 3.1.3"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "active_support"
  s.add_development_dependency "autotest-rails"
end


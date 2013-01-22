Gem::Specification.new do |s|
  s.name         = "update_dependencies"
  s.version      = "0.1.2"
  s.authors      = "dougdroper"
  s.email        = ["dougdroper@gmail.com"]
  s.homepage     = "https://gist.github.com/4566388"
  s.summary      = "Updates dependencies of gemfile from gemfile.lock"
  s.description  = "Prints a new Gemfile with the gem versions matched to the independent gemfile.lock"
  s.executables  = ["update_dependencies"]

  s.files        = ["update_dependencies.rb"]
  s.require_path = "."
end
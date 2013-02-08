# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "./lib/http/stub/version"

Gem::Specification.new do |s|
  s.name = "http_stub"
  s.version = Http::Stub::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Matthew Ueckerman", "Russell Van Bert"]
  s.summary = %q{A Http Server replaying configured stub responses}
  s.description = %q{Configure server responses via requests to /stub.  Intended as an acceptance / integration testing tool.}
  s.email = %q{matthew.ueckerman@myob.com}
  s.homepage = "http://github.com/MYOB-Technology/http_stub"
  s.rubyforge_project = "http_stub"
  s.license = "MIT"

  s.required_ruby_version = '>= 1.9.3'

  s.files        = Dir.glob("./lib/**/*")
  s.test_files   = Dir.glob("./spec/**/*")
  s.require_path = "lib"
end

# -*- encoding: utf-8 -*-
$:.push ::File.expand_path("../lib", __FILE__)
require "http_stub/version"

Gem::Specification.new do |spec|
  spec.name              = "http_stub"
  spec.version           = HttpStub::VERSION
  spec.platform          = Gem::Platform::RUBY
  spec.authors           = ["Matthew Ueckerman", "Russell Van Bert"]
  spec.summary           = "A HTTP Server replaying configured stub responses"
  spec.description       = "fakeweb for a HTTP server, informing it to stub / fake responses"
  spec.email             = "matthew.ueckerman@myob.com"
  spec.homepage          = "http://github.com/MYOB-Technology/http_stub"
  spec.rubyforge_project = "http_stub"
  spec.license           = "MIT"

  spec.files      = Dir.glob("./lib/**/*")
  spec.test_files = Dir.glob("./spec/**/*")

  spec.require_path = "lib"

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_runtime_dependency "rake", "~> 10.4"

  spec.add_dependency "sinatra",             "~> 1.4"
  spec.add_dependency "sinatra-partial",     "~> 0.4"
  spec.add_dependency "multipart-post",      "~> 2.0"
  spec.add_dependency "http_server_manager", "~> 0.4"
  spec.add_dependency "json-schema",         "~> 2.6"
  spec.add_dependency "activesupport",       "~> 4.2"
  spec.add_dependency "haml",                "~> 4.0"
  spec.add_dependency "sass",                "~> 3.4"

  spec.add_development_dependency "travis-lint",               "~> 2.0"
  spec.add_development_dependency "metric_fu",                 "~> 4.12"
  spec.add_development_dependency "rspec",                     "~> 3.4"
  spec.add_development_dependency "simplecov",                 "~> 0.11"
  spec.add_development_dependency "rack-test",                 "~> 0.6"
  spec.add_development_dependency "json",                      "~> 1.8"
  spec.add_development_dependency "nokogiri",                  "~> 1.6"
  spec.add_development_dependency "httparty",                  "~> 0.13"
  spec.add_development_dependency "wait_until",                "~> 0.1"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
end

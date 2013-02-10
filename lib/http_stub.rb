require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'json'
require 'uri'
require 'net/http'

require File.expand_path('../http/stub/server', __FILE__)
require File.expand_path('../http/stub/client', __FILE__)

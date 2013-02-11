require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'sinatra'
require 'immutable_struct'
require 'net/http'
require 'json'

require File.expand_path('../http/stub/stub', __FILE__)
require File.expand_path('../http/stub/registry', __FILE__)
require File.expand_path('../http/stub/server', __FILE__)
require File.expand_path('../http/stub/client', __FILE__)

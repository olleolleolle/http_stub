require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'sinatra'
require 'net/http'
require 'json'

require File.expand_path('../http/stub/server', __FILE__)
require File.expand_path('../http/stub/client', __FILE__)

self.instance_eval do
  alias :namespace_pre_sinatra :namespace if self.respond_to?(:namespace, true)
end

require 'sinatra/namespace'

self.instance_eval do
  alias :namespace :namespace_pre_sinatra if self.respond_to?(:namespace_pre_sinatra, true)
end

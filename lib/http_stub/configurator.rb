require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/indifferent_access'

require_relative 'extensions/core/hash/indifferent_and_insensitive_access'
require_relative 'extensions/core/hash/with_indifferent_and_insensitive_access'

require_relative 'configurator/stub/stub'
require_relative 'configurator/stub/template'
require_relative 'configurator/stub'
require_relative 'configurator/scenario'
require_relative 'configurator/endpoint_template'
require_relative 'configurator/state'
require_relative 'configurator/server'
require_relative 'configurator/part'

module HttpStub

  module Configurator

    def self.included(mod)
      mod.extend(HttpStub::Configurator::ClassMethods)
      mod.send(:include, HttpStub::Configurator::InstanceMethods)
    end

    module ClassMethods

      def state
        @state ||= HttpStub::Configurator::State.new
      end

      def stub_server
        @stub_server ||= HttpStub::Configurator::Server.new(state)
      end

      def parts=(parts)
        parts.each do |name, part|
          part.apply_to(self)
          self.define_singleton_method(name) { part }
          self.send(:define_method, name) { part }
        end
      end

    end

    module InstanceMethods

      def state
        self.class.state
      end

      def stub_server
        self.class.stub_server
      end

    end

  end

end

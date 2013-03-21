module HttpStub

  module Rake

    class StartServerTask < ::Rake::TaskLib

      def initialize(options)
        desc "Starts stub #{options[:name]}"
        task "start_#{options[:name]}" do
          HttpStub::Server.instance_eval do
            set :port, options[:port]
            run!
          end
        end
      end

    end

  end

end

module Rescuetime
  module Extension
    @extensions = {}

    def self.included(klass)
      # TODO: raise "No APPLICATION constant defined."

      app = klass::APPLICATION.to_s
      if @extensions[app]
        warn <<-WARN
          Extension for given APPLICATION (#{app}) allready exists.
          Class: #{klass}
          Trace: #{caller.first.inspect}
        WARN
      end

      @extensions[app] = klass
    end

    def self.extensions
      @extensions
    end

    def self.get(key)
      @extensions[key.to_s]
    end
  end
end


module Rescuetime
  module Debug
    # Debug-mode turned on?
    def debug?
      @debug == true
    end

    private
      # Debug-Wrapper
      def debug(msg = nil, &block)
        return unless debug?

        puts msg if msg
        yield if block_given?
      end
  end
end


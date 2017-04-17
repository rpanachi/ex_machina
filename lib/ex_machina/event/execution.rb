module ExMachina
  module Event
    class Execution
      attr_reader :event, :errors, :assigns

      def initialize(event = nil)
        @event   = event
        @errors  = []
        @assigns = {}
      end

      def success?
        errors.empty?
      end

      def break!
        throw :break
      end

      def abort!(message)
        error!(message)
        break!
      end

      def error!(error)
        errors << error if error
        error
      end

      def assign!(key, value)
        assigns[key] = value
        assigns
      end
    end
  end
end

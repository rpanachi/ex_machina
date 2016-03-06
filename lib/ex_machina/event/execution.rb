module ExMachina
  module Event
    class Execution

      STATUSES = [
        SUCCESS = :success,
        FAILURE = :failure,
        ERROR   = :error,
        SKIPPED = :skipped
      ].freeze

      attr_accessor :previous, :current
      attr_accessor :result

      attr_reader :event, :transition

      def initialize(event, transition)
        @event      = event
        @transition = transition
      end

      def running?
        @running
      end

      def start!
        @run      = false
        @running  = true
        @result   = nil
        @previous = event.status
        @current  = nil
      end

      def finish!(value)
        return result unless running?

        @running = false
        @ran     = true

        if value == true
          success!
        elsif value == false
          failure!
        elsif value == :skipped
          skipped!
        elsif value == :error
          error!
        else
          @result = value
        end
      end
      def run?
        !!@ran
      end

      def success?
        result == :success
      end
      def success!
        @current = transition.to
        finish!(@result = :success)
      end

      def failure?
        result == :failure
      end
      def failure!
        @current = @previous
        finish!(@result = :failure)
      end

      def skipped!
        finish!(@result = :skipped)
      end
      def skipped?
        result == :skipped
      end

      def error!(exception)
        # TODO handle exception
        finish!(@result = :error)
      end
      def error?
        result == :error
      end

      def eligible?
        if transition.conditional?
          if transition.do_if
            invoke(transition.do_if)
          elsif transition.do_unless
            !invoke(transition.do_unless)
          end
        else
          true
        end
      end

      def run
        start!

        return skipped! unless eligible?

        invoke(transition.do_before)
        begin
          call = invoke(:perform)
          invoke(transition.do_after)
          finish!(call)
        rescue StandardError => ex
          error!(ex)
        end

        if success?
          invoke(:transit)
          invoke(transition.do_success)
        elsif failure?
          invoke(transition.do_failure)
        end

        call
      end

      protected

      def invoke(meth, arg = self)
        Util.invoke_method(event, meth, arg)
      end
    end
  end
end

module ExMachina
  module Transition
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
        @current  = event.status
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
          error!(@exception)
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
        @current = previous
        finish!(@result = :failure)
      end

      def skipped!
        finish!(@result = :skipped)
      end
      def skipped?
        result == :skipped
      end

      def error!(exception)
        @exception = exception
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

        begin
          invoke(callback(:before), true)
          if (performed = invoke(:perform, true))
            success!
          else
            failure!
          end
          invoke(:transit)
          invoke(callback(:after))

        rescue StandardError => ex
          error!(ex)
        end

        if success?
          invoke(callback(:success))
        elsif failure?
          invoke(callback(:failure))
        elsif error?
          invoke(callback(:error))
        elsif skipped?
          invoke(callback(:skip))
        else
          # do what?
        end

        performed
      end

      protected

      # return the transition 'do_callback' or default '(before|after)_transition method
      def callback(name)
        transition.send("do_#{name}") || "#{name}_#{previous}_to_#{current}"
      end

      def invoke(meth, default = nil)
        result = Util.invoke_method(event, meth, self)
        return default if result.nil?
        result
      end
    end
  end
end

module ExMachina
  module Event
    class Runner

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
          invoke(event, transition.do_if, self) ||
            invoke(event, transition.do_unless, self)
        else
          true
        end
      end

      def run
        start!

        return skipped! unless eligible?

        invoke(event, transition.do_before, self)
        begin
          call = invoke(event, :call, self)
          invoke(event, transition.do_after, self)
          finish!(call)
        rescue StandardError => ex
          error!(ex)
        end

        if success?
          invoke(event, :change_status, self)
          invoke(event, transition.do_success, self)
        elsif failure?
          invoke(event, transition.do_failure, self)
        end

        call
      end

      def invoke(context, meth, *args)
        return if meth.nil?

        if meth.respond_to?(:call)
          all_args    = Array([context, *args])
          meth_params = meth.parameters
          meth_args   = *all_args.first(meth_params.size)

          meth.call(*meth_args)

        elsif context.respond_to?(meth)
          meth_params = context.method(meth).parameters
          meth_args   = *args.first(meth_params.size)

          context.send(meth, *meth_args)
        end
      end
    end
  end
end

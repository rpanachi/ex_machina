module ExMachina
  module Event
    class Transition

      attr_reader :from, :to
      attr_reader :do_if, :do_unless, :do_before, :do_after, :do_success, :do_failure

      def initialize(options)
        @from    = Array(options.fetch(:from)).map { |status| normalize(status) }
        @to      = normalize(options.fetch(:to))

        # optional args
        @do_if      = options[:if]
        @do_unless  = options[:unless]
        @do_before  = options[:before]
        @do_after   = options[:after]
        @do_success = options[:success]
        @do_failure = options[:failure]
      end

      def from?(status)
        from.include?(normalize(status))
      end

      def to?(status)
        Array(to).include?(normalize(status))
      end

      def conditional?
        !do_if.nil? || !do_unless.nil?
      end

      private

      def normalize(status)
        status.to_s.to_sym
      end
    end
  end
end

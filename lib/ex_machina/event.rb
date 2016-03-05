require "ex_machina/event/transition"
require "ex_machina/event/runner"
require "ex_machina/event/validations"

module ExMachina
  module Event
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base.include(Validations)
    end

    module ClassMethods
      def transitions
        @transitions ||= []
      end
      def transition(*args)
        transitions << Transition.new(*args)
      end
      def fire(context)
        self.new(context).fire
      end
      def fire!(context)
        self.new(context).fire!
      end
      def can_fire?(context)
        self.new(context).can_fire?
      end
      def event
        self.name.demodulize.underscore
      end
    end

    module InstanceMethods
      attr_reader :context

      def initialize(context)
        @context = context
      end

      def transitions
        self.class
          .transitions
          .select { |transition| transition.from?(status) }
      end

      def status
        context.status
      end

      def change_status(execution)
        context.status = execution.current.to_s
        context.save
      end

      def fire
        validate
        return unless can_fire?

        result = false
        within_transaction do
          transitions.each do |transition|
            runner = Runner.new(self, transition)
            result = runner.run

            break result unless runner.skipped?
          end
        end
        result
      end

      def fire!
        raise error_messages unless can_fire?
        fire
      end

      def can_fire?
        validate
        valid?
      end

      def call
        raise NotImplementedError, "method 'call' must be implemented on event class"
      end

      def within_transaction(&block)
        # TODO implement strategy for transaction
        DB.transaction(&block)
      end
    end
  end
end

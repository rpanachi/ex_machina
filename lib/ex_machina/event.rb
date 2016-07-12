require "ex_machina/event/transition"
require "ex_machina/event/validations"
require "ex_machina/event/execution"
require "ex_machina/errors"
require "ex_machina/adapter"

module ExMachina
  module Event
    def self.included(base)
      base.extend  ClassMethods
      base.include InstanceMethods
      base.include Validations
      base.include Adapter
    end

    module ClassMethods
      def transitions
        @transitions ||= []
      end
      def transition(*args)
        transitions << Transition.new(*args)
      end
      def fire(context)
        execution = self.new(context).fire
        execution.success?
      end
      def fire!(context)
        execution = self.new(context).fire

        execution.success? || (
          raise execution.error || ExMachina::TransitionError.new("Unable to perform #{self.class.event}")
        )
      end
      def can_fire?(context)
        self.new(context).can_fire?
      end
      def event
        @event ||= Util::String.new(self.name).demodulize.underscore
      end
    end

    module InstanceMethods
      attr_reader :context

      def initialize(context)
        @context = context
      end

      # Available transitions
      def transitions
        self.class
          .transitions
          .select { |transition| transition.from?(status) }
      end

      # The context current status
      def status
        context.status
      end

      # Called on event success
      def transit(execution)
        context.status = execution.current.to_s
        persist(context)
      end

      # Override this method on event implementation
      def perform
        true
      end

      def fire
        validate
        execution = nil

        if valid?
          within_transaction do
            transitions.each do |transition|
              execution = Execution.new(self, transition)
              execution.run

              result = execution.current
              break if execution.success?
            end
          end
        else
          execution = Execution.new(self)
          exception = InvalidTransition.new(error_messages)
          execution.invalid!(exception)
        end

        execution
      end

      def can_fire?
        validate
        valid?
      end
    end
  end
end

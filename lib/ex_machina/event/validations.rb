module ExMachina
  module Event
    module Validations
      def errors
        @errors ||= []
      end
      def valid?
        errors.empty?
      end
      def validate
        errors.clear

        unless transitions.any?
          errors << "No transitions defined from '#{status}' status"
        end
      end
      def validate!
        validate
        raise InvalidTransition, error_messages unless valid?
      end
      def error_messages
        errors.join(", ")
      end
    end
  end
end

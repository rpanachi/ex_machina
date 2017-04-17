module ExMachina
  module Transition
    module Validation
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
      def error_messages
        errors.join(", ")
      end
    end
  end
end

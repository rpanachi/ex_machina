module ExMachina
  module Eventable
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module ClassMethods
      def events
        @events ||= []
      end
      def has_events(*event_classes)
        event_classes.each do |event_class|
          events << event_class

          define_method "#{event_class.event}" do
            event_class.fire(self)
          end
          define_method "#{event_class.event}!" do
            event_class.fire!(self)
          end
          define_method "can_#{event_class.event}?" do
            event_class.can_fire?(self)
          end
          events << event_class
        end
      end
    end

    module InstanceMethods
    end
  end
end

module ExMachina
  module Event
    module Runner
      def call(**params)
        execution = Event::Execution.new(self)

        catch :break do
          self.validate(execution, params)
          self.perform(execution, params) if execution.success?
          self.after(execution, params)
        end

      rescue StandardError => e
        execution.error!("(%s) %s" % [e.class, e.message])

      ensure
        return execution
      end

      def perform(execution, **params)
        raise NotImplementedError,
          "You should implement method:\n   perform(execution, **params)"
      end

      def validate(execution, **params)
        # optional implementation
      end

      def after(execution, **params)
        # optional implementation
      end
    end
  end
end

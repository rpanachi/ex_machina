module ExMachina
  module Adapter
    module Memory
      def within_transaction(&block)
        block.call
      end

      def persist(model)
        # do nothing
      end
    end
  end
end

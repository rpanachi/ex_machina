module ExMachina
  module Adapter
    module ActiveRecord
      def within_transaction(&block)
        raise NotImplementedError, "not supported yet"
      end

      def persist(model)
        model.save
      end
    end
  end
end

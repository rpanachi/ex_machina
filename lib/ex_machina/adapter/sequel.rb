module ExMachina
  module Adapter
    module Sequel
      def within_transaction(&block)
        DB.transaction(&block)
      end

      def persist(model)
        model.save
      end
    end
  end
end

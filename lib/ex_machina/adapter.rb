require "ex_machina/adapter/memory"
require "ex_machina/adapter/sequel"
require "ex_machina/adapter/active_record"

module ExMachina
  module Adapter
    def self.included(base)
      if defined?(::Sequel)
        base.include Adapter::Sequel
      elsif defined?(::ActiveRecord)
        base.include Adapter::ActiveRecord
      else
        base.include Adapter::Memory
      end
    end
  end
end


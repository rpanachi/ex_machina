require "ex_machina/event/execution"
require "ex_machina/event/runner"

module ExMachina
  module Event
    def self.included(base)
      base.include Runner
    end
  end
end

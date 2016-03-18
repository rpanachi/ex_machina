class Engine
  include ExMachina::Machine

  attr_accessor :status, :fuel
  def initialize(status = "stopped", fuel = 10)
    @status, @fuel = status, fuel
  end
end

class Engine::Start
  include ExMachina::Event

  transition from: :stopped, to: :running,
    if:    :has_fuel?,
    after: :consumes_fuel

  def has_fuel?
    context.fuel > 0
  end

  def perform(execution)
    execution.success!
  end

  def consumes_fuel(execution)
    context.fuel -= 1
  end
end

class Engine::Stop
  include ExMachina::Event

  transition from: :running, to: :stopped
end

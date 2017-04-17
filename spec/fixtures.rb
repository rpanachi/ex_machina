class SimpleEvent
  include ExMachina::Event

  def perform(execution, **params)
    action = params.fetch(:action, :success)

    if action == :success
      message = params.fetch(:message, "success message")
      execution.assign!(:message, message)

    elsif action == :abort
      execution.abort!("execution aborted")

    elsif action == :error
      raise "Unknown error was thrown"
    end
  end

  def validate(execution, **params)
    if params.has_key?(:invalid)
      execution.error!("There is an validation")
    end
  end
end

class Engine
  include ExMachina::Machine

  attr_accessor :status, :fuel
  def initialize(status = "stopped", fuel = 10)
    @status, @fuel = status, fuel
  end
end

class Engine::Start
  include ExMachina::Event
  include ExMachina::Transition

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
  include ExMachina::Transition

  transition from: :running, to: :stopped
end

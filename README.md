# ExMachina

A simple implementation of (Finine-state)[https://en.wikipedia.org/wiki/Finite-state_machine] using OOP following the principles:

- Machine: a set of status, events and transitions
- Status: the state of a machine
- Events: a action performed on each status
- Transitions: the graph of events and status

The *machine* is declared on target class that knowns the possible status and events. Each event should be implemented on its own class, where the transitions are declared too. ExMachina manages the flow, execution and transitions of each event and status.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ex_machina'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ex_machina

## Usage

Include the `ExMachina::Machine` on target object and define the status and events calling `has_status` and `has_events` respectively:

Here a classic example of a state machine of an Engine, which have too events: start and stop:

```
class Engine
  include ExMachina::Machine

  has_status [:stopped, :running]
  has_events Engine::Start, Engine::Stop

  attr_accessor :status, :fuel

  def initialize(attributes = {})
    @status = attributes.fetch(:status, "stopped")
    @fuel   = attributes.fetch(:fuel, 10)
  end
end
```

And implement each event on its own class. Here was made on subclasses:

```
class Engine::Start
  include ExMachina::Event

  transition from: :stopped, to: :running, if: :has_fuel?, after: :consumes_fuel

  def has_fuel?
    context.fuel > 0
  end

  def perform(execution)
    engage_transmission

    execution.success!
  end

  def consumes_fuel(execution)
    context.fuel -= 1
  end

  protected

  def engage_transmission
    # do something
  end
end

class Engine::Stop
  include ExMachina::Event

  transition from: :running, to: :stopped
end
```

Here is an usage example:

```
engine = Engine.new     # => #<Engine:0x007fb77c065758>
engine.status           # "stopped" 
engine.fuel             # 10

engine.can_start?       # true
engine.start            # true
engine.status           # "running"

engine.running?         # true
engine.start            # false
engine.errors           # ["No transitions defined from 'running' status"]

engine.stop             # true
engine.status           # "stopped"
engine.stopped?         # true
engine.fuel             # 9

engine.fuel = 0         # 0
engine.can_start?       # false
engine.start            # false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ex_machina. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

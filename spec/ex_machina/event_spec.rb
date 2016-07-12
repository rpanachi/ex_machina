require 'spec_helper'
require 'fixtures'

describe ExMachina::Event do

  describe ".event" do
    subject { Engine::Start }

    it "extract event name from class" do
      expect(subject.event).to eq("start")
    end
  end

  context "class methods" do
    let(:engine) { Engine.new }
    subject { Engine::Start }

    describe ".fire" do
      it "true on success" do
        result = subject.fire(engine)
        expect(result).to be_truthy
      end
      it "false on failure or error" do
        engine.status = "xxx"
        result = subject.fire(engine)
        expect(result).to be_falsy
      end
    end
    describe ".fire!" do
      it "true on success" do
        result = subject.fire!(engine)
        expect(result).to be_truthy
      end
      it "raise error on failure or error" do
        engine.status = "xxx"
        expect { subject.fire!(engine) }.to raise_error(ExMachina::InvalidTransition)
      end
    end
    describe ".can_fire?" do
      it "validates" do
        expect_any_instance_of(subject).to receive(:can_fire?)

        subject.can_fire?(engine)
      end
    end
  end

  context "instance methods" do
    let(:engine) { Engine.new("stopped") }
    subject { Engine::Start.new(engine) }

    describe "#fire" do
      it "is successful" do
        result = subject.fire

        expect(result).to be_success
        expect(result.current).to eq(:running)
        expect(engine.status).to eq("running")
      end

      it "validate transition" do
        engine.status = "unknown"

        result = subject.fire
        expect(result).to be_invalid
        expect(result.error).to_not be_nil
      end

      it "trust on 'perform' result" do
        expect(subject).to receive(:perform).and_return(false)

        result = subject.fire

        expect(result).to be_failure
        expect(result.current).to eq("stopped")
      end

      it "is skipped if transition is conditional" do
        expect(subject).to receive(:has_fuel?).and_return(false)

        result = subject.fire

        expect(result).to be_skipped
        expect(result.current).to eq("stopped")
      end

      it "handle errors on result" do
        expect(subject).to receive(:consumes_fuel)
          .and_raise("Unexpected error")

        result = subject.fire

        expect(result).to_not be_success
        expect(result).to be_error
        expect(result.error).to_not be_nil

        expect(engine.status).to eq("running")
      end
    end

    describe ".can_fire?" do
      it "valid" do
        expect(subject).to be_can_fire
      end

      it "invalid" do
        engine.status = "unknown"

        expect(subject).to_not be_can_fire
      end
    end
  end
end

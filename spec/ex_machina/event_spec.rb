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
      it "call fire on event instance" do
        expect_any_instance_of(subject).to receive(:fire)

        subject.fire(engine)
      end
    end
    describe ".fire!" do
      it "call fire! on event instance" do
        expect_any_instance_of(subject).to receive(:fire!)

        subject.fire!(engine)
      end
    end
    describe ".can_fire?" do
      it "call can_fire! on event instance" do
        expect_any_instance_of(subject).to receive(:can_fire?)

        subject.can_fire?(engine)
      end
    end
  end

  context "instance methods" do
    describe "#fire" do
      let(:engine) { Engine.new(status: "stopped") }
      subject { Engine::Start.new(engine) }

      it "is successful" do
        expect(subject.fire).to eq(true)
      end
      it "validate transition" do
        engine.status = "unknown"

        result = subject.fire
        expect(subject.errors).to_not be_empty
      end
      it "change context status" do
        result = subject.fire

        expect(engine.status).to eq("running")
      end
      it "trust on 'perform' result" do
        expect(subject).to receive(:perform).and_return(false)

        expect(subject.fire).to eq(false)
      end
      it "is skipped if transition is conditional" do
        expect(subject).to receive(:has_fuel?).and_return(false)

        expect(subject.fire).to eq(false)
      end
    end

    describe ".fire!" do

    end

    describe ".can_fire?" do

    end
  end
end

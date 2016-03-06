require 'spec_helper'
require 'fixtures'

describe ExMachina::Machine do

  context "included" do
    it "base respond to .has_events" do
      expect(Engine).to respond_to(:has_events)
    end
  end

  context ".has_events" do
    context "define event methods on base" do
      before  { Engine.has_events(Engine::Start) }
      subject { Engine.new }

      it { is_expected.to respond_to(:start) }
      it { is_expected.to respond_to(:start!) }
      it { is_expected.to respond_to(:can_start?) }
    end
  end
end

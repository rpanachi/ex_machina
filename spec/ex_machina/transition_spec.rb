require "spec_helper"

describe ExMachina::Transition::Definition do

  subject { described_class.new(from: :stopped, to: "running") }

  it { is_expected.to respond_to(:from) }
  it { is_expected.to respond_to(:to) }
  it { is_expected.to respond_to(:do_if) }
  it { is_expected.to respond_to(:do_unless) }
  it { is_expected.to respond_to(:do_before) }
  it { is_expected.to respond_to(:do_after) }
  it { is_expected.to respond_to(:do_success) }
  it { is_expected.to respond_to(:do_failure) }

  it "normalize statuses into symbol" do
    expect(subject.to).to eq(:running)
  end

  it "normalize from status into array" do
    expect(subject.from).to eq([:stopped])
  end

  describe "#from?" do
    it "check transition start from status" do
      transition = described_class.new(from: [:a, :b], to: :c)

      expect(transition.from?(:a)).to be_truthy
      expect(transition.from?(:b)).to be_truthy
      expect(transition.from?("a")).to be_truthy
      expect(transition.from?("b")).to be_truthy
      expect(transition.from?(:c)).to be_falsy
    end
  end

  describe "#to?" do
    it "check transition finish to status" do
      transition = described_class.new(from: [:a, :b], to: :c)

      expect(transition.to?(:c)).to be_truthy
      expect(transition.to?("c")).to be_truthy
      expect(transition.to?(:a)).to be_falsy
    end
  end

  describe "#conditional?" do
    it "when if option was assigned" do
      transition = described_class.new(from: :a, to: :b, if: :valid?)
      expect(transition).to be_conditional
    end

    it "when unless option was assigned" do
      transition = described_class.new(from: :a, to: :b, unless: :valid?)
      expect(transition).to be_conditional
    end
  end
end

require "spec_helper"
require "fixtures"

describe ExMachina::Event do
  subject { SimpleEvent.new }

  context "when included on class" do
    it "respond_to call" do
      expect(subject).to respond_to(:call)
    end
    it "respond_to perform" do
      expect(subject).to respond_to(:perform)
    end
  end

  describe ".call" do
    it "invoke validate and perform methods" do
      args = {message: "hello world"}

      expectation = ->(execution, params) do
        expect(execution).to_not be_nil
        expect(params).to eq(args)
      end

      expect(subject).to receive(:validate, &expectation)
      expect(subject).to receive(:perform, &expectation)

      subject.call(args)
    end

    it "don't call perform if validation fails" do
      expect(subject).to receive(:validate) do |execution, params|
        execution.error!("There is an error")
      end
      expect(subject).to_not receive(:perform)

      subject.call
    end

    it "always return a new execution" do
      execution = subject.call

      expect(execution).to_not be_nil
    end

    it "return execution even on error" do
      expect(subject).to receive(:perform) {
        raise "UnexpectedError"
      }

      execution = subject.call
      expect(execution).to_not be_success

      errors = execution.errors
      expect(errors).to include("(RuntimeError) UnexpectedError")
    end
  end

  describe ".validate" do
    it "process execution and parameters" do
      args      = {success: true}
      execution = double(:execution, success?: true)

      subject.validate(execution, args)

      expect(execution).to be_success
    end
  end

  describe ".perform" do
    it "process execution and parameters" do
      args      = {success: true}
      execution = double(:execution, success?: true, assign!: {})

      subject.perform(execution, args)

      expect(execution).to be_success
    end
  end
end

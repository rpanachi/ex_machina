require "spec_helper"
require "fixtures"

describe ExMachina::Event::Execution do
  let(:event) { SimpleEvent.new }

  subject { described_class.new(event) }

  describe ".success?" do
    it "true when no errors" do
      expect(subject).to be_success
    end
    it "false when has errors" do
      subject.error!("oops")

      expect(subject).to_not be_success
    end
  end

  describe ".error!" do
    it "add error to execution" do
      subject.error!("invalid")

      expect(subject.errors).to include("invalid")
    end
  end

  describe ".assign!" do
    it "add key/value to execution" do
      subject.assign!(:hello, "world")

      expect(subject.assigns).to include(hello: "world")
    end
  end

  describe ".abort!" do
    it "add error and break execution" do
      expect {
        subject.abort!("fatal error")
      }.to throw_symbol(:break)

      expect(subject).to_not be_success
      expect(subject.errors).to include("fatal error")
    end
  end
end

require 'spec_helper'

describe ExMachina::Util do

  describe ExMachina::Util::String do
    subject { described_class }

    describe "#demodulize" do
      it "extract class" do
        value = subject.new("MyModule::MyClass")
        expect(value.demodulize).to eq("MyClass")
      end
    end

    describe "#underscore" do
      it "convert camel case words" do
        value = subject.new("WordInCamelCase")
        expect(value.underscore).to eq("word_in_camel_case")
      end
    end
  end

  describe ".invoke_method" do
    class Target
      def a_value
        2
      end
      def a_meth(arg)
        "#{arg}:#{a_value}"
      end
    end

    subject { described_class }
    let(:target) { Target.new }

    context "with lambda" do
      it "and matching args" do
        meth   = lambda { |target, arg| target.a_value * arg }
        result = subject.invoke_method(target, meth, 10)

        expect(result).to eq(20)
      end

      it "and no args" do
        meth   = lambda { "no args" }
        result = subject.invoke_method(target, meth, 10)

        expect(result).to eq("no args")
      end

      it "and more than expected args" do
        meth   = lambda { |target, arg1, arg2| arg1 + arg2 }
        result = subject.invoke_method(target, meth, 10, 30, 50)

        expect(result).to eq(40)
      end
    end

    context "with method name" do
      it "and matching args" do
        result = subject.invoke_method(target, :a_meth, "abc")

        expect(result).to eq("abc:2")
      end
      it "and no args" do
        result = subject.invoke_method(target, "a_value")

        expect(result).to eq(2)
      end
      it "and more than expected args" do
        result = subject.invoke_method(target, :a_value, "not expected arg")

        expect(result).to eq(2)
      end
    end
  end
end

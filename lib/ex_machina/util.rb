module ExMachina
  module Util
    class String < ::String
      # Convert 'MyModule::MyClass' to 'MyClass'
      def demodulize
        self.split("::").last
      end

      # Convert 'MyClass' to 'my_class'
      def underscore
        self
          .gsub("::", "/")
          .gsub(/(^[A-Z])/) { |match| "#{match.downcase}" }
          .gsub(/([A-Z])/) { |match| "_#{match.downcase}" }
      end
    end

    extend self

    # Invoke method or lambda on given context passing correspondent args
    def invoke_method(context, meth, *args)
      return if meth.nil?

      if meth.respond_to?(:call)
        all_args    = Array([context, *args])
        meth_params = meth.parameters
        meth_args   = *all_args.first(meth_params.size)

        meth.call(*meth_args)

      elsif context.respond_to?(meth)
        meth_params = context.method(meth).parameters
        meth_args   = *args.first(meth_params.size)

        context.send(meth, *meth_args)
      end
    end
  end
end

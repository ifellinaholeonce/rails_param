require 'forwardable'

module RailsParam
  module Param
    class Validator
      extend Forwardable

      attr_reader :parameter

      def_delegators :parameter, :name, :options, :value

      def initialize(parameter)
        @parameter = parameter
      end

      def validate!
        options.each_key do |key|
          klass = camelize(key)
          Validator.const_get(klass).new(parameter).valid!
        end
      end

      def valid!
        raise InvalidParameterError, error_message unless valid_value?
      end

      private

      def camelize(term)
        string = term.to_s
        string.split('_').collect(&:capitalize).join
      end

      def error_message
        "Error message must be defined on Validator subclass"
      end

      def valid_value?
        # Should be overwritten in subclass
        false
      end
    end
  end
end
module RailsParam
  module Param
    class Validator
      class Required < Validator
        private

        def valid_value?
          value.present? && options[:required]
        end

        def error_message
          "Parameter #{name} is required"
        end
      end
    end
  end
end

module RailsParam
  module Param
    class Coercion
      class IntegerParam < VirtualParam
        def coerce
          param.nil? ? nil : Integer(param)
        end
      end
    end
  end
end

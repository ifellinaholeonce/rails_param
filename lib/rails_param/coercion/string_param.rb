module RailsParam
  module Param
    class Coercion
      class StringParam < VirtualParam
        def coerce
          param.nil? ? nil : String(param)
        end
      end
    end
  end
end

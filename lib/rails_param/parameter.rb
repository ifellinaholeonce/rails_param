module RailsParam
  class MockController
    attr_accessor :params, :name, :type, :options

    def initialize(params, name, type, options = {})
      @params = params
      @name = name.is_a?(Integer)? name : name.to_s
      @type = type
      @options = options
      # @block = block
    end

    def my_begin(&block)
      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      # coerce value
      coerced_value = coerce(
        params[name],
        type,
        options
      )
      parameter = RailsParam::Parameter.new(
        name: name,
        value: coerced_value,
        type: type,
        options: options,
        &block
      )

      parameter.set_default if parameter.should_set_default?

      # validate presence
      if params[name].nil? && options[:required]
        raise InvalidParameterError.new(
          "Parameter #{name} is required",
          param: name,
          options: options
        )
      end

      if block_given?
        if parameter.type == Array
          parameter.value.each_with_index do |element, i|
            if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
              recurse element, &block
            else
              parameter.value[i] = recurse({ i => element }, i, &block) # supply index as key unless value is hash
            end
          end
        else
          recurse parameter.value, &block
        end
      end

      # apply transformation
      parameter.transform if params.include?(name) && options[:transform]

      # validate
      validate!(parameter)

      # set params value
      params[name] = parameter.value
    end

    private

    def recurse(element, index = nil)
      raise InvalidParameterError, 'no block given' unless block_given?

      struct = Struct.new(:params) do
        def param!(*args, **kwargs, &block)
          MockController.new(params, *args, **kwargs).my_begin(&block)
        end
      end

      yield(struct.new(element), index)
    end

    def check_param_presence? param
      !param.nil?
    end

    def coerce(param, type, options = {})
      begin
        return param if (param.is_a?(type) rescue false)

        Coercion.new(param, type, options).coerce
      rescue ArgumentError, TypeError
        raise InvalidParameterError, "'#{param}' is not a valid #{type}"
      end
    end

    def validate!(param)
      param.validate
    end
  end

  class Parameter
    attr_accessor :name, :value, :options, :type

    TIME_TYPES = [Date, DateTime, Time].freeze
    STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

    def initialize(name:, value:, options: {}, type: nil, &block)
      @name = name
      @value = value
      @options = options
      @type = type
    end

    def validate_presence
      if name.nil? && options[:required]
        raise InvalidParameterError.new(
          "Parameter #{name} is required",
          param: name,
          options: options
        )
      end
    end

    def should_set_default?
      value.nil? && check_param_presence?(options[:default])
    end

    def set_default
      self.value = options[:default].respond_to?(:call) ? options[:default].call : options[:default]
    end

    def transform
      self.value = options[:transform].to_proc.call(value)
    end

    def validate
      Validator.new(self).validate!
    end

    private

    def check_param_presence?(param)
      !param.nil?
    end
  end
end

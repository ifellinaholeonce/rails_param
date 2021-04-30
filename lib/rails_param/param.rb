require 'pry'
module RailsParam
  def param!(name, type, options = {}, &block)
    MockController.new(params, name, type, options).my_begin(&block)
  end
end

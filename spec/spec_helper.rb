require 'simplecov'
SimpleCov.start

require 'active_support'
require 'bigdecimal'
require 'date'

require 'action_controller'
require 'fixtures/controllers'
require 'rails_param'
require 'rspec/rails'
Dir["./spec/rails_param/validator/shared_examples/**/*.rb"].sort.each { |f| require f }

require 'spec_helper'

describe RailsParam::Validator do
  let(:name)    { "foo" }
  let(:value)   { "bar" }
  let(:options) { { required: true } }
  let(:type)    { String }
  let(:parameter) do
    RailsParam::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  let(:validator_class)  { RailsParam::Validator::Required }
  let(:validator_double) { double }

  before :each do
    allow(validator_double).to receive(:valid!)
    allow(validator_class).to receive(:new).and_return(validator_double)
  end

  describe "#validate!" do
    it "initializes a validator class based on the provided option" do
      subject.validate!

      expect(validator_class).to have_received(:new).with(parameter)
    end
  end

  describe "#valid!" do
    it "raises an InvalidParameterError if not subclassed" do
      expect { subject.valid! }.to raise_error RailsParam::InvalidParameterError
    end
  end
end

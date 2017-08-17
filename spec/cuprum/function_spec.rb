require 'cuprum/function'
require 'cuprum/function_examples'

RSpec.describe Cuprum::Function do
  include Spec::Examples::FunctionExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::NotImplementedError' do
    let(:error_class) { described_class::NotImplementedError }

    it { expect(described_class).to have_constant(:NotImplementedError) }

    it 'should be an error class' do
      expect(error_class).to be_a Class
      expect(error_class).to be < StandardError
    end # it
  end # describe

  include_examples 'should implement the Function methods'
end # describe

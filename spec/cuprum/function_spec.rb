require 'cuprum/function'
require 'cuprum/function_examples'

RSpec.describe Cuprum::Function do
  include Spec::Examples::FunctionExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { Cuprum::Result }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Function methods'

  include_examples 'should implement the generic Function methods'

  describe '#errors' do
    include_examples 'should have private reader', :errors
  end # describe
end # describe

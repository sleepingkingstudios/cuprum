# frozen_string_literal: true

require 'support/matrix'

RSpec.describe Spec::Matrix do # rubocop:disable RSpec/FilePath
  subject(:matrix) { described_class.new(example_group) }

  let(:example_context) do
    instance_double(RSpec::Core::ExampleGroup)
  end
  let(:example_group) do
    class_double(RSpec::Core::ExampleGroup, context: example_context)
  end

  describe '#new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#evaluate' do
    before(:example) do
      allow(example_group).to receive(:context) do |name|
        class_double(RSpec::Core::ExampleGroup, name: name)
      end
    end

    it 'should define the method' do
      expect(matrix)
        .to respond_to(:evaluate)
        .with(0).arguments
        .and_any_keywords
        .and_a_block
    end

    describe 'with no scenarios' do
      let(:scenarios) { {} }

      it 'should not define an example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).not_to have_received(:context)
      end

      it 'should not yield control' do
        expect { |block| matrix.evaluate(**scenarios, &block) }
          .not_to yield_control
      end
    end

    describe 'with one scenario with one value' do
      let(:scenarios) { { english: { 'one' => 1 } } }
      let(:expected) do
        { 'with one' => { english: 1 } }
      end

      it 'should define one example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(1).times
      end

      it 'should generate the example group' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end

    describe 'with one scenario with many values' do
      let(:english) do
        {
          'one'   => 1,
          'two'   => 2,
          'three' => 3
        }
      end
      let(:scenarios) { { english: english } }
      let(:expected) do
        {
          'with one'   => { english: 1 },
          'with two'   => { english: 2 },
          'with three' => { english: 3 }
        }
      end

      it 'should define three example groups' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(3).times
      end

      it 'should generate the example group' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end

    describe 'with two scenarios with one value each' do
      let(:scenarios) do
        {
          english: { 'one' => 1 },
          spanish: { 'uno' => 1 }
        }
      end
      let(:expected) do
        { 'with one and uno' => { english: 1, spanish: 1 } }
      end

      it 'should define each example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(1).times
      end

      it 'should generate the example groups' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end

    describe 'with two scenarios with many values each' do
      let(:scenarios) do
        {
          english: {
            'one'   => 1,
            'two'   => 2,
            'three' => 3
          },
          spanish: {
            'uno'  => 1,
            'dos'  => 2,
            'tres' => 3
          }
        }
      end
      let(:expected) do
        {
          'with one and uno'    => { english: 1, spanish: 1 },
          'with one and dos'    => { english: 1, spanish: 2 },
          'with one and tres'   => { english: 1, spanish: 3 },
          'with two and uno'    => { english: 2, spanish: 1 },
          'with two and dos'    => { english: 2, spanish: 2 },
          'with two and tres'   => { english: 2, spanish: 3 },
          'with three and uno'  => { english: 3, spanish: 1 },
          'with three and dos'  => { english: 3, spanish: 2 },
          'with three and tres' => { english: 3, spanish: 3 }
        }
      end

      it 'should define each example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(9).times
      end

      it 'should generate the example groups' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end

    describe 'with many scenarios with one value each' do
      let(:scenarios) do
        {
          english:  { 'one'  => 1 },
          spanish:  { 'uno'  => 1 },
          japanese: { 'ichi' => 1 }
        }
      end
      let(:expected) do
        {
          'with one, uno, and ichi' => { english: 1, spanish: 1, japanese: 1 }
        }
      end

      it 'should define one example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(1).times
      end

      it 'should generate the example group' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end

    describe 'with many scenarios with many values each' do
      let(:scenarios) do
        {
          english: {
            'one'   => 1,
            'two'   => 2,
            'three' => 3
          },
          spanish: {
            'uno'  => 1,
            'dos'  => 2,
            'tres' => 3
          },
          japanese: {
            'ichi' => 1,
            'ni'   => 2,
            'san'  => 3
          }
        }
      end

      it 'should define each example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(27).times
      end
    end

    describe 'with a scenario with an empty label' do
      let(:scenarios) do
        {
          english: {
            'one'   => 1,
            'two'   => 2,
            'three' => 3
          },
          capitalize: {
            ''                  => nil,
            'capitalize: false' => false,
            'capitalize: true'  => true
          }
        }
      end
      let(:expected) do
        {
          'with one' =>
            { english: 1, capitalize: nil },
          'with one and capitalize: false' =>
            { english: 1, capitalize: false },
          'with one and capitalize: true' =>
            { english: 1, capitalize: true },
          'with two' =>
            { english: 2, capitalize: nil },
          'with two and capitalize: false' =>
            { english: 2, capitalize: false },
          'with two and capitalize: true' =>
            { english: 2, capitalize: true },
          'with three' =>
            { english: 3, capitalize: nil },
          'with three and capitalize: false' =>
            { english: 3, capitalize: false },
          'with three and capitalize: true' =>
            { english: 3, capitalize: true }
        }
      end

      it 'should define each example group' do
        matrix.evaluate(**scenarios) {}

        expect(example_group).to have_received(:context).exactly(9).times
      end

      it 'should generate the example groups' do
        contexts = {}

        matrix.evaluate(**scenarios) do |properties|
          contexts[name] = properties
        end

        expect(contexts).to be == expected
      end
    end
  end

  describe '#example_group' do
    include_examples 'should have reader', :example_group, -> { example_group }
  end
end

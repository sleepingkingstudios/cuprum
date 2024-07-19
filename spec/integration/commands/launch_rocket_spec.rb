# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/launch_rocket'
require 'support/models/rocket'

RSpec.describe Spec::Commands::LaunchRocket do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new }

  let(:rocket) do
    Spec::Models::Rocket.new(attributes: { name: 'Imp IV', launched: false })
  end
  let(:launch_site) { 'KSC' }
  let(:payload)     { { name: 'Satellite', mass: 500 } }

  describe '#call' do
    let(:expected_error) do
      Cuprum::Errors::InvalidParameters
        .new(command_class: described_class, failures:)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(1).argument
        .and_keywords(:launch_site, :payload)
    end

    def call_command
      command.call(rocket, launch_site:, payload:)
    end

    it { expect(call_command).to be_a_passing_result }

    it { expect { call_command }.to change(rocket, :launched).to be true }

    describe 'with launch_site: an empty String' do
      let(:launch_site) { '' }
      let(:failures)    { ["launch pad can't be blank"] }

      it 'should return a failing result with an InvalidParameters error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with payload: { mass: too high }' do
      let(:payload)  { super().merge(mass: 10_000) }
      let(:failures) { ['payload is too heavy'] }

      it 'should return a failing result with an InvalidParameters error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with rocket: nil' do
      let(:rocket)   { nil }
      let(:failures) { ['rocket is not an instance of Spec::Models::Rocket'] }

      it 'should return a failing result with an InvalidParameters error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with rocket: a launched rocket' do
      let(:rocket) do
        Spec::Models::Rocket.new(attributes: { name: 'Imp IV', launched: true })
      end
      let(:failures) { ['rocket has already launched'] }

      it 'should return a failing result with an InvalidParameters error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it { expect { call_command }.not_to change(rocket, :launched) }
    end

    describe 'with multiple invalid parameters' do
      let(:rocket) do
        Spec::Models::Rocket.new(attributes: { name: 'Imp IV', launched: true })
      end
      let(:launch_site) { '' }
      let(:payload)     { super().merge(mass: 10_000) }
      let(:failures) do
        [
          "launch pad can't be blank",
          'payload is too heavy',
          'rocket has already launched'
        ]
      end

      it 'should return a failing result with an InvalidParameters error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end

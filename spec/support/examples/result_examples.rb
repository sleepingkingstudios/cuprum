# frozen_string_literal: true

require 'forwardable'

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ResultExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    module EqualityExamples
      extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

      shared_context 'with an object that wraps a result' do
        let(:other) { Spec::ResultWrapper.new(other_result) }

        example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
          klass.extend Forwardable

          klass.def_delegators :result, :to_h
        end
      end

      shared_context 'with an object that wraps the result methods' do
        let(:other) { Spec::ResultMethodsWrapper.new(other_result) }

        before(:example) do
          allow(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
            .to receive(:deprecate)
        end

        example_class 'Spec::ResultMethodsWrapper' do |klass|
          klass.extend Forwardable

          klass.define_method(:initialize) do |result|
            @result = result
          end

          klass.attr_reader :result

          klass.def_delegators :result, :error, :status, :value
        end
      end

      shared_examples 'should compare the results' do |kwargs|
        let(:other_value)  { kwargs.fetch(:value) }
        let(:other_error)  { kwargs.fetch(:error) }
        let(:other_status) { kwargs.fetch(:status) }
        let(:other_result) do
          described_class.new(
            value:  other_value,
            error:  other_error,
            status: other_status
          )
        end
        let(:other) { defined?(super()) ? super() : other_result }
        let(:expected) do
          %i[error status value]
            .map { |method| result.send(method) == other_result.send(method) }
            .reduce(true) { |memo, bool| memo && bool }
        end

        it { expect(result == other).to be expected }
      end

      shared_examples 'should compare the results in each scenario' \
      do |scenarios|
        Spec::Matrix.new(self).evaluate(**scenarios) \
        do |value:, error:, status:|
          include_examples 'should compare the results',
            value:,
            error:,
            status:
        end

        context 'with a result hash' do
          let(:other) { other_result.to_h }

          Spec::Matrix.new(self).evaluate(**scenarios) \
          do |value:, error:, status:|
            include_examples 'should compare the results',
              value:,
              error:,
              status:
          end
        end

        wrap_context 'with an object that wraps the result methods' do
          let(:other_result) { described_class.new }

          it 'should print a deprecation warning' do
            described_class.new == other # rubocop:disable Lint/Void

            expect(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
              .to have_received(:deprecate)
              .with(
                'Cuprum::Result#==',
                message: 'The compared object must respond to #to_h.'
              )
          end

          Spec::Matrix.new(self).evaluate(**scenarios) \
          do |value:, error:, status:|
            include_examples 'should compare the results',
              value:,
              error:,
              status:
          end
        end

        wrap_context 'with an object that wraps a result' do
          Spec::Matrix.new(self).evaluate(**scenarios) \
          do |value:, error:, status:|
            include_examples 'should compare the results',
              value:,
              error:,
              status:
          end
        end
      end
    end

    shared_context 'when the result has a value' do
      let(:value) { 'returned value' }

      before(:example) { params[:value] = value }
    end

    shared_context 'when the result has an error' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

      before(:example) { params[:error] = error }
    end

    shared_context 'when the result has status: :failure' do
      before(:example) { params[:status] = :failure }
    end

    shared_context 'when the result has status: :success' do
      before(:example) { params[:status] = :success }
    end
  end
end

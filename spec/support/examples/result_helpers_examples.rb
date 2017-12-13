require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ResultHelpersExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the ResultHelpers methods' do
      shared_context 'when the instance is executing the implementation' do
        def call_with_implementation &block
          example  = self
          instance =
            described_class.new { example.instance_exec(self, &block) }

          instance.call
        end # method implement_with
      end # shared_context

      describe '#errors' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:errors, :allow_private => true).
            with_value(nil)
        end # it

        it { expect(instance.send(:errors)).to be_nil }

        wrap_context 'when the instance is executing the implementation' do
          let(:expected_errors) do
            ['errors.messages.unknown']
          end # let

          it 'should be an empty array' do
            call_with_implementation do |instance|
              errors = instance.send(:errors)

              expect(errors).to be_a Array
              expect(errors).to be_empty
            end # call_with_implementation
          end # it

          it 'should update the result errors' do
            result =
              call_with_implementation do |instance|
                expected_errors.each { |msg| instance.send(:errors) << msg }
              end # call_with_implementation

            expected_errors.each do |message|
              expect(result.errors).to include message
            end # each
          end # it

          context 'when the function has a custom #build_errors method' do
            let(:described_class) do
              Class.new(super()) do
                def build_errors
                  Spec::Errors.new
                end # method build_errors
              end # class
            end # let

            example_constant 'Spec::Errors' do
              # rubocop:disable RSpec/InstanceVariable
              Class.new(Delegator) do
                def initialize
                  @errors = []

                  super(@errors)
                end # constructor

                def __getobj__
                  @errors
                end # method

                def __setobj__ ary
                  @errors = ary
                end # method __setobj__
              end # class
              # rubocop:enable RSpec/InstanceVariable
            end # constant

            it 'should be an empty errors object' do
              call_with_implementation do |instance|
                errors = instance.send(:errors)

                expect(errors).to be_a Spec::Errors
                expect(errors).to be_empty
              end # call_with_implementation
            end # it
          end # context
        end # context
      end # describe

      describe '#failure!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:failure!)

          expect(instance).to respond_to(:failure!, true).with(0).arguments
        end # it

        it { expect(instance.send(:failure!)).to be_nil }

        wrap_context 'when the instance is executing the implementation' do
          it { expect(instance.send(:failure!)).to be_nil }

          it 'should mark the result as failing' do
            result =
              call_with_implementation do |instance|
                instance.send(:failure!)

                nil
              end # call_with_implementation

            expect(result.failure?).to be true
          end # it
        end # method wrap_context
      end # describe

      describe '#halt!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:halt!)

          expect(instance).to respond_to(:halt!, true).with(0).arguments
        end # it

        it { expect(instance.send(:halt!)).to be_nil }

        wrap_context 'when the instance is executing the implementation' do
          it { expect(instance.send(:halt!)).to be_nil }

          it 'should halt the result' do
            result =
              call_with_implementation do |instance|
                instance.send(:halt!)

                nil
              end # call_with_implementation

            expect(result.halted?).to be true
          end # it
        end # method wrap_context
      end # describe
    end # shared_examples
  end # module
end # module

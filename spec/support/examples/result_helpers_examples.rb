require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ResultHelpersExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the ResultHelpers methods' do
      shared_context 'when the command has a current result' do
        let(:result) { instance_double(Cuprum::Result) }

        before(:example) do
          allow(instance).to receive(:result).and_return(result)
        end # before example
      end # shared_context

      describe '#errors' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:errors, :allow_private => true).
            with_value(nil)
        end # it

        it { expect(instance.send(:errors)).to be_nil }

        wrap_context 'when the command has a current result' do
          let(:errors) { [] }

          before(:example) do
            allow(result).to receive(:errors).and_return(errors)
          end # before example

          it 'should delegate to the result' do
            expect(instance.send(:errors)).to be errors
          end # it
        end # wrap_context
      end # describe

      describe '#failure!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:failure!)

          expect(instance).to respond_to(:failure!, true).with(0).arguments
        end # it

        it { expect(instance.send(:failure!)).to be_nil }

        wrap_context 'when the command has a current result' do
          before(:example) { allow(result).to receive(:failure!) }

          it 'should delegate to the result' do
            instance.send(:failure!)

            expect(result).to have_received(:failure!).with(no_args)
          end # it
        end # wrap_context
      end # describe

      describe '#halt!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:halt!)

          expect(instance).to respond_to(:halt!, true).with(0).arguments
        end # it

        it { expect(instance.send(:halt!)).to be_nil }

        wrap_context 'when the command has a current result' do
          before(:example) { allow(result).to receive(:halt!) }

          it 'should delegate to the result' do
            instance.send(:halt!)

            expect(result).to have_received(:halt!).with(no_args)
          end # it
        end # wrap_context
      end # describe

      describe '#success!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:success!)

          expect(instance).to respond_to(:success!, true).with(0).arguments
        end # it

        it { expect(instance.send(:success!)).to be_nil }

        wrap_context 'when the command has a current result' do
          before(:example) { allow(result).to receive(:success!) }

          it 'should delegate to the result' do
            instance.send(:success!)

            expect(result).to have_received(:success!).with(no_args)
          end # it
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module

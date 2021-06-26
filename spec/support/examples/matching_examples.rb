# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module MatchingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Matching interface' do
      describe '.match' do
        it 'should define the class method' do
          expect(described_class)
            .to respond_to(:match)
            .with(1).argument
            .and_keywords(:error, :value)
            .and_a_block
        end
      end

      describe '#call' do
        it { expect(matcher).to respond_to(:call).with(1).argument }
      end

      describe '#match_context' do
        include_examples 'should define reader', :match_context
      end

      describe '#match_context?' do
        include_examples 'should define predicate', :match_context?
      end

      describe '#matches?' do
        it 'should define the method' do
          expect(matcher)
            .to respond_to(:matches?)
            .with(1).argument
            .and_keywords(:error, :value)
        end
      end
    end

    shared_examples 'should implement the Matching methods' do
      shared_context 'when the matcher matches :failure' do
        before(:example) do
          described_class.match(:failure, &wrapper('failure'))
        end
      end

      shared_context 'when the matcher matches :failure and an error' do
        before(:example) do
          described_class.match(
            :failure,
            error: Spec::CustomError,
            &wrapper('failure: Spec::CustomError')
          )
        end
      end

      shared_context 'when the matcher matches :failure and a value' do
        before(:example) do
          described_class.match(
            :failure,
            value: Spec::RocketPart,
            &wrapper('failure: Spec::RocketPart')
          )
        end
      end

      shared_context 'when the matcher matches :failure, a value,' \
                     ' and an error' \
      do
        before(:example) do
          described_class.match(
            :failure,
            error: Spec::CustomError,
            value: Spec::RocketPart,
            &wrapper('failure: Spec::RocketPart and Spec::CustomError')
          )
        end
      end

      shared_context 'when the matcher matches :success' do
        before(:example) do
          described_class.match(:success, &wrapper('success'))
        end
      end

      shared_context 'when the matcher matches :success and a value' do
        before(:example) do
          described_class.match(
            :success,
            value: Spec::RocketPart,
            &wrapper('success: Spec::RocketPart')
          )
        end
      end

      shared_context 'when the matcher matches multiple statuses' do
        before(:example) do
          described_class.match(:success, &wrapper('success'))

          described_class.match(
            :success,
            value: Spec::RocketEngine,
            &wrapper('success: Spec::RocketEngine')
          )

          described_class.match(
            :success,
            value: Spec::RocketPart,
            &wrapper('success: Spec::RocketPart')
          )

          described_class.match(:failure, &wrapper('failure'))

          described_class.match(
            :failure,
            error: Spec::SubclassError,
            &wrapper('failure: Spec::SubclassError')
          )

          described_class.match(
            :failure,
            error: Spec::CustomError,
            &wrapper('failure: Spec::CustomError')
          )

          described_class.match(
            :failure,
            value: Spec::RocketPart,
            &wrapper('failure: Spec::RocketPart')
          )

          described_class.match(
            :failure,
            error: Spec::CustomError,
            value: Spec::RocketPart,
            &wrapper('failure: Spec::RocketPart and Spec::CustomError')
          )
        end
      end

      shared_context 'when the matcher inherits from another matcher' do
        let(:described_class) { Class.new(super()) }

        before(:example) do
          matcher_class.match(:failure, &wrapper('inherit failure'))

          matcher_class.match(
            :failure,
            error: Spec::CustomError,
            &wrapper('inherit failure: Spec::CustomError')
          )

          matcher_class.match(:success, &wrapper('inherit success'))

          matcher_class.match(
            :success,
            value: Spec::RocketPart,
            &wrapper('inherit success: Spec::RocketPart')
          )
        end
      end

      shared_context 'when the matcher includes another matcher' do
        example_constant 'Spec::IncludedMatcher' do
          Module.new.include Cuprum::Matching
        end

        before(:example) do
          described_class.include(Spec::IncludedMatcher)

          described_class.match(:failure, &wrapper('failure'))

          Spec::IncludedMatcher.match(
            :failure,
            error: Spec::CustomError,
            &wrapper('include failure: Spec::CustomError')
          )

          described_class.match(:success, &wrapper('success'))

          Spec::IncludedMatcher.match(
            :success,
            value: Spec::RocketPart,
            &wrapper('include success: Spec::RocketPart')
          )
        end
      end

      let(:implementation) { ->(message, _result = nil) { message } }

      def wrapper(message)
        msg  = message
        impl = implementation

        -> { instance_exec(msg, &impl) }
      end

      describe '.match' do
        describe 'with status: nil' do
          let(:error_message) { "status can't be blank" }

          it 'should raise an exception' do
            expect { described_class.match(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with status: an Object' do
          let(:error_message) { 'status must be a Symbol' }

          it 'should raise an exception' do
            expect { described_class.match(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with status: an empty Symbol' do
          let(:error_message) { "status can't be blank" }

          it 'should raise an exception' do
            expect { described_class.match(:'') }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with status: a value and error: an Object' do
          let(:error_message) { 'error must be a Class or Module' }

          it 'should raise an exception' do
            expect { described_class.match(:failure, error: Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with status: a value and value: an Object' do
          let(:error_message) { 'value must be a Class or Module' }

          it 'should raise an exception' do
            expect { described_class.match(:failure, value: Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end
      end

      describe '#call' do
        shared_examples 'should call the match clause' do |message|
          it { expect(matcher.call(result)).to be == message }

          context 'when the match clause takes a result parameter' do
            def wrapper(message)
              msg  = message
              impl = implementation

              ->(result) { instance_exec(msg, result, &impl) }
            end

            it { expect(matcher.call(result)).to be == message }
          end

          wrap_context 'when the matcher has a context' do
            it { expect(matcher.call(result)).to be == message.upcase }

            it 'should call the helper method' do
              allow(context).to receive(:helper).and_call_original

              matcher.call(result)

              expect(context).to have_received(:helper).with(message, nil)
            end

            context 'when the match clause takes a result parameter' do
              def wrapper(message)
                msg  = message
                impl = implementation

                ->(result) { instance_exec(msg, result, &impl) }
              end

              it { expect(matcher.call(result)).to be == message.upcase }

              it 'should call the helper method' do
                allow(context).to receive(:helper)

                matcher.call(result)

                expect(context).to have_received(:helper).with(message, result)
              end
            end
          end
        end

        shared_examples 'should raise a NoMatchError' do
          let(:error_message) { "no match found for #{result.inspect}" }

          it 'should raise an exception' do
            expect { matcher.call(result) }
              .to raise_error described_class::NoMatchError, error_message
          end
        end

        example_class 'Spec::CustomError', Cuprum::Error

        example_class 'Spec::SubclassError', 'Spec::CustomError'

        example_class 'Spec::RocketPart'

        example_class 'Spec::RocketEngine', 'Spec::RocketPart'

        describe 'with nil' do
          let(:error_message) { 'result must be a Cuprum::Result' }

          it 'should raise an exception' do
            expect { matcher.call(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:error_message) { 'result must be a Cuprum::Result' }

          it 'should raise an exception' do
            expect { matcher.call(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a result' do
          let(:result) { Cuprum::Result.new }

          include_examples 'should raise a NoMatchError'
        end

        describe 'with a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :failure' do
            include_examples 'should call the match clause', 'failure'
          end

          wrap_context 'when the matcher matches :failure and an error' do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches :failure and a value' do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches multiple statuses' do
            include_examples 'should call the match clause', 'failure'
          end

          wrap_context 'when the matcher inherits from another matcher' do
            include_examples 'should call the match clause', 'inherit failure'
          end

          wrap_context 'when the matcher includes another matcher' do
            include_examples 'should call the match clause', 'failure'
          end
        end

        describe 'with a failing result with an error' do
          let(:error) { Spec::CustomError }
          let(:result) do
            Cuprum::Result.new(status: :failure, error: error.new)
          end

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :failure' do
            include_examples 'should call the match clause', 'failure'
          end

          wrap_context 'when the matcher matches :failure and an error' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should call the match clause', 'failure'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'failure: Spec::SubclassError'
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should call the match clause', 'inherit failure'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'inherit failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'inherit failure: Spec::CustomError'
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should call the match clause', 'failure'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'include failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'include failure: Spec::CustomError'
            end
          end
        end

        describe 'with a failing result with a value' do
          let(:value) { Spec::RocketPart }
          let(:result) do
            Cuprum::Result.new(status: :failure, value: value.new)
          end

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :failure' do
            include_examples 'should call the match clause', 'failure'
          end

          wrap_context 'when the matcher matches :failure and an error' do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches :failure and a value' do
            describe 'with a non-matching value' do
              let(:value) { String }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching value' do
              let(:value) { String }

              include_examples 'should call the match clause', 'failure'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            include_examples 'should call the match clause', 'inherit failure'
          end

          wrap_context 'when the matcher includes another matcher' do
            include_examples 'should call the match clause', 'failure'
          end
        end

        describe 'with a failing result with a value and an error' do
          let(:error) { Spec::CustomError }
          let(:value) { Spec::RocketPart }
          let(:result) do
            Cuprum::Result.new(
              status: :failure,
              error:  error.new,
              value:  value.new
            )
          end

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :failure' do
            include_examples 'should call the match clause', 'failure'
          end

          wrap_context 'when the matcher matches :failure and an error' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            describe 'with a non-matching value' do
              let(:value) { String }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }
              let(:value) { Spec::RocketPart }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a non-matching value' do
              let(:error) { Spec::CustomError }
              let(:value) { String }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching error and value' do
              let(:error) { Spec::CustomError }
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart and Spec::CustomError'
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching error and value' do
              let(:error) { Class.new(Cuprum::Error) }
              let(:value) { String }

              include_examples 'should call the match clause', 'failure'
            end

            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart'
            end

            describe 'with a non-matching value' do
              let(:error) { Spec::CustomError }
              let(:value) { String }

              include_examples 'should call the match clause',
                'failure: Spec::CustomError'
            end

            describe 'with a matching error and value' do
              let(:error) { Spec::CustomError }
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'failure: Spec::RocketPart and Spec::CustomError'
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should call the match clause', 'inherit failure'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'inherit failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'inherit failure: Spec::CustomError'
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              include_examples 'should call the match clause', 'failure'
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              include_examples 'should call the match clause',
                'include failure: Spec::CustomError'
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              include_examples 'should call the match clause',
                'include failure: Spec::CustomError'
            end
          end
        end

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :success' do
            include_examples 'should call the match clause', 'success'
          end

          wrap_context 'when the matcher matches :success and a value' do
            include_examples 'should raise a NoMatchError'
          end

          wrap_context 'when the matcher matches multiple statuses' do
            include_examples 'should call the match clause', 'success'
          end

          wrap_context 'when the matcher inherits from another matcher' do
            include_examples 'should call the match clause', 'inherit success'
          end

          wrap_context 'when the matcher includes another matcher' do
            include_examples 'should call the match clause', 'success'
          end
        end

        describe 'with a passing result with a value' do
          let(:value) { String }
          let(:result) do
            Cuprum::Result.new(status: :success, value: value.new)
          end

          include_examples 'should raise a NoMatchError'

          wrap_context 'when the matcher matches :success' do
            include_examples 'should call the match clause', 'success'
          end

          wrap_context 'when the matcher matches :success and a value' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              include_examples 'should raise a NoMatchError'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'success: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'success: Spec::RocketPart'
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              include_examples 'should call the match clause', 'success'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'success: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'success: Spec::RocketEngine'
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              include_examples 'should call the match clause', 'inherit success'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'inherit success: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'inherit success: Spec::RocketPart'
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              include_examples 'should call the match clause', 'success'
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              include_examples 'should call the match clause',
                'include success: Spec::RocketPart'
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              include_examples 'should call the match clause',
                'include success: Spec::RocketPart'
            end
          end
        end
      end

      describe '#match_context' do
        it { expect(matcher.match_context).to be nil }

        wrap_context 'when the matcher has a context' do
          it { expect(matcher.match_context).to be context }
        end
      end

      describe '#match_context?' do
        it { expect(matcher.match_context?).to be false }

        wrap_context 'when the matcher has a context' do
          it { expect(matcher.match_context?).to be true }
        end
      end

      describe '#matches?' do
        let(:error_message) { 'argument must be a result or a status' }

        example_class 'Spec::CustomError', Cuprum::Error

        example_class 'Spec::SubclassError', 'Spec::CustomError'

        example_class 'Spec::RocketPart'

        example_class 'Spec::RocketEngine', 'Spec::RocketPart'

        describe 'with nil' do
          it 'should raise an exception' do
            expect { matcher.matches?(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          it 'should raise an exception' do
            expect { matcher.matches?(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with result: a result and error: value' do
          let(:error_message) { 'error defined by result' }
          let(:result)        { Cuprum::Result.new }

          it 'should raise an exception' do
            expect { matcher.matches?(result, error: -> {}) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with result: a result and value: value' do
          let(:error_message) { 'value defined by result' }
          let(:result)        { Cuprum::Result.new }

          it 'should raise an exception' do
            expect { matcher.matches?(result, value: -> {}) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with result: a failing result' do
          let(:result) { Cuprum::Result.new(status: :failure) }

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches :failure and a value' do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end
        end

        describe 'with result: a failing result with an error' do
          let(:error) { Spec::CustomError }
          let(:result) do
            Cuprum::Result.new(status: :failure, error: error.new)
          end

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end
        end

        describe 'with result: a failing result with a value' do
          let(:value) { String }
          let(:result) do
            Cuprum::Result.new(status: :failure, value: value.new)
          end

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches :failure and a value' do
            describe 'with a non-matching value' do
              let(:value) { String }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end
        end

        describe 'with result: a failing result with a value and an error' do
          let(:value) { String }
          let(:error) { Spec::CustomError }
          let(:result) do
            Cuprum::Result.new(
              status: :failure,
              error:  error.new,
              value:  value.new
            )
          end

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            describe 'with a non-matching value' do
              let(:value) { String }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a non-matching value' do
              let(:error) { Spec::CustomError }
              let(:value) { String }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching value and error' do
              let(:error) { Spec::CustomError }
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(result)).to be true }
            end
          end
        end

        describe 'with result: a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :success' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :success and a value' do
            it { expect(matcher.matches?(result)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(result)).to be true }
          end
        end

        describe 'with result: a passing result with a value' do
          let(:value) { String }
          let(:result) do
            Cuprum::Result.new(status: :success, value: value.new)
          end

          it { expect(matcher.matches?(result)).to be false }

          wrap_context 'when the matcher matches :success' do
            it { expect(matcher.matches?(result)).to be true }
          end

          wrap_context 'when the matcher matches :success and a value' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it { expect(matcher.matches?(result)).to be false }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(result)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(result)).to be true }
            end
          end
        end

        describe 'with status: :failure' do
          it { expect(matcher.matches?(:failure)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(:failure)).to be true }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            it { expect(matcher.matches?(:failure)).to be false }
          end

          wrap_context 'when the matcher matches :failure and a value' do
            it { expect(matcher.matches?(:failure)).to be false }
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(:failure)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it { expect(matcher.matches?(:failure)).to be true }
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(:failure)).to be true }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(:failure)).to be true }
          end
        end

        describe 'with status: :failure and error: a Class' do
          let(:error) { Spec::CustomError }

          it { expect(matcher.matches?(:failure, error: error)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(:failure, error: error)).to be false }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, error: error)).to be false
              end
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            it { expect(matcher.matches?(:failure, error: error)).to be false }
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(:failure, error: error)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, error: error)).to be false
              end
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, error: error)).to be false
              end
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, error: error)).to be false
              end
            end

            describe 'with a matching error' do
              let(:error) { Spec::CustomError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end

            describe 'with a subclass of the error' do
              let(:error) { Spec::SubclassError }

              it { expect(matcher.matches?(:failure, error: error)).to be true }
            end
          end
        end

        describe 'with status: :failure and value: a Class' do
          let(:value) { Spec::RocketPart }

          it { expect(matcher.matches?(:failure, value: value)).to be false }

          wrap_context 'when the matcher matches :failure' do
            it { expect(matcher.matches?(:failure, value: value)).to be false }
          end

          wrap_context 'when the matcher matches :failure and an error' do
            it { expect(matcher.matches?(:failure, value: value)).to be false }
          end

          wrap_context 'when the matcher matches :failure and a value' do
            describe 'with a non-matching value' do
              let(:value) { String }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:failure, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:failure, value: value)).to be true }
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            it { expect(matcher.matches?(:failure, value: value)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching value' do
              let(:value) { String }

              it 'should not match the status' do
                expect(matcher.matches?(:failure, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:failure, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:failure, value: value)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(:failure, value: value)).to be false }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(:failure, value: value)).to be false }
          end
        end

        describe 'with status: failure, error: a Class, and value: a Class' do
          let(:error) { Spec::CustomError }
          let(:value) { Spec::RocketPart }

          it 'should not match the parameters' do
            expect(matcher.matches?(:failure, error: error, value: value))
              .to be false
          end

          wrap_context 'when the matcher matches :failure' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be false
            end
          end

          wrap_context 'when the matcher matches :failure and an error' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be false
            end
          end

          wrap_context 'when the matcher matches :failure and a value' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be false
            end
          end

          wrap_context 'when the matcher matches :failure, a value,' \
                       ' and an error' \
          do
            describe 'with a non-matching error' do
              let(:error) { Class.new(Cuprum::Error) }
              let(:value) { Spec::RocketPart }

              it 'should not match the parameters' do
                expect(matcher.matches?(:failure, error: error, value: value))
                  .to be false
              end
            end

            describe 'with a non-matching value' do
              let(:error) { Spec::CustomError }
              let(:value) { String }

              it 'should not match the parameters' do
                expect(matcher.matches?(:failure, error: error, value: value))
                  .to be false
              end
            end

            describe 'with a matching error and value' do
              let(:error) { Spec::CustomError }
              let(:value) { Spec::RocketPart }

              it 'should match the parameters' do
                expect(matcher.matches?(:failure, error: error, value: value))
                  .to be true
              end
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be true
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be false
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            it 'should not match the parameters' do
              expect(matcher.matches?(:failure, error: error, value: value))
                .to be false
            end
          end
        end

        describe 'with status: :success' do
          it { expect(matcher.matches?(:success)).to be false }

          wrap_context 'when the matcher matches :success' do
            it { expect(matcher.matches?(:success)).to be true }
          end

          wrap_context 'when the matcher matches :success and a value' do
            it { expect(matcher.matches?(:success)).to be false }
          end

          wrap_context 'when the matcher matches multiple statuses' do
            it { expect(matcher.matches?(:success)).to be true }
          end

          wrap_context 'when the matcher inherits from another matcher' do
            it { expect(matcher.matches?(:success)).to be true }
          end

          wrap_context 'when the matcher includes another matcher' do
            it { expect(matcher.matches?(:success)).to be true }
          end
        end

        describe 'with status: :success and value: a Class' do
          let(:value) { String }

          it { expect(matcher.matches?(:success, value: value)).to be false }

          wrap_context 'when the matcher matches :success' do
            it { expect(matcher.matches?(:success, value: value)).to be false }
          end

          wrap_context 'when the matcher matches :success and a value' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it 'should not match the parameters' do
                expect(matcher.matches?(:success, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end
          end

          wrap_context 'when the matcher matches multiple statuses' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it 'should not match the parameters' do
                expect(matcher.matches?(:success, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end
          end

          wrap_context 'when the matcher inherits from another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it 'should not match the parameters' do
                expect(matcher.matches?(:success, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end
          end

          wrap_context 'when the matcher includes another matcher' do
            describe 'with a non-matching value' do
              let(:value) { Object }

              it 'should not match the parameters' do
                expect(matcher.matches?(:success, value: value)).to be false
              end
            end

            describe 'with a matching value' do
              let(:value) { Spec::RocketPart }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end

            describe 'with a subclass of the value' do
              let(:value) { Spec::RocketEngine }

              it { expect(matcher.matches?(:success, value: value)).to be true }
            end
          end
        end
      end
    end
  end
end

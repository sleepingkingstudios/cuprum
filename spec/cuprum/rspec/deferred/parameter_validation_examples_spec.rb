# frozen_string_literal: true

require 'rspec/sleeping_king_studios/sandbox'

require 'cuprum/rspec/deferred/parameter_validation_examples'

RSpec.describe Cuprum::RSpec::Deferred::ParameterValidationExamples do
  let(:fixture_file) do
    %w[
      spec/cuprum/rspec/deferred/parameter_validation_examples_spec.fixtures.rb
    ]
  end
  let(:result) do
    RSpec::SleepingKingStudios::Sandbox.run(fixture_file)
  end
  let(:expected_failing) do
    <<~EXAMPLES.lines.map(&:strip)
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with message: value when the parameters are valid should return a failing result with InvalidParameters error
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with message: value when the parameters are invalid with non-matching errors should return a failing result with InvalidParameters error
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with type: value when the parameters are valid should return a failing result with InvalidParameters error
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with type: value when the parameters are invalid with non-matching errors should return a failing result with InvalidParameters error
    EXAMPLES
  end
  let(:expected_passing) do
    <<~EXAMPLES.lines.map(&:strip)
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with message: value when the parameters are invalid with matching error should return a failing result with InvalidParameters error
      Cuprum::RSpec::Deferred::ParameterValidationExamples "should validate the parameter" examples with type: value when the parameters are invalid with matching error should return a failing result with InvalidParameters error
    EXAMPLES
  end

  it { expect(result.summary).to be == '6 examples, 4 failures' }

  it { expect(result.failing_examples).to be == expected_failing }

  it { expect(result.passing_examples).to be == expected_passing }
end

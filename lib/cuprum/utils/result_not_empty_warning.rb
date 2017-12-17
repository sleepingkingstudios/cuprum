require 'cuprum/utils'

module Cuprum::Utils
  # Helper class for building a warning message when a command returns a result,
  # but the command's current result already has errors, a set status, or is
  # halted.
  class ResultNotEmptyWarning
    MESSAGE = '#process returned a result, but '.freeze
    private_constant :MESSAGE

    # @param result [Cuprum::Result] The result for which to generate the
    #   warning message.
    def initialize result
      @result = result
    end # constructor

    # @return [String] The warning message for the given result.
    def message
      # byebug
      MESSAGE + humanize_list(warnings).freeze
    end # method message

    private

    attr_reader :result

    def errors_not_empty_warning
      return nil if result.errors.empty?

      "there were already errors #{@result.errors.inspect}".freeze
    end # method errors_not_empty_warning

    def halted_warning
      return nil unless result.halted?

      'the command was halted'.freeze
    end # method halted_warning

    def humanize_list list, empty_value: ''
      return empty_value if list.size.zero?

      return list.first.to_s if list.size == 1

      return "#{list.first} and #{list.last}" if list.size == 2

      "#{list[0...-1].join ', '}, and #{list.last}"
    end # method humanize_list

    def status_set_warning
      status = result.send(:status)

      return nil if status.nil?

      "the status was set to #{status.inspect}".freeze
    end # method status_set_warning

    def warnings
      [
        errors_not_empty_warning,
        status_set_warning,
        halted_warning
      ].compact
    end # method warnings
  end # class
end # module

# frozen_string_literal: true

require 'set'

require 'cuprum/utils'

module Cuprum::Utils
  # Utility class mapping a method's parameters by parameter name.
  class ParametersMapping
    # Generates a parameters mapping for the given method or Proc.
    #
    # @param callable [#parameters] the method or Proc for which to map
    #   parameters.
    #
    # @return [ParametersMapping] the mapping for the callable object.
    def self.build(callable) # rubocop:disable Metrics/MethodLength
      arguments          = []
      block              = nil
      keywords           = []
      variadic_arguments = nil
      variadic_keywords  = nil

      callable.parameters.each do |(type, name)|
        case type
        when :opt, :req
          arguments << name
        when :key, :keyreq
          keywords << name
        when :rest
          variadic_arguments = name
        when :keyrest
          variadic_keywords = name
        when :block
          block = name
        end
      end

      new(
        arguments:,
        block:,
        keywords:,
        variadic_arguments:,
        variadic_keywords:
      )
    end

    # @param arguments [Array<Symbol>] the named arguments to the method, both
    #   required and optional, but excluding variadic args).
    # @param block [Symbol, nil] the name of the block parameter, if any.
    # @param keywords [Array<Symbol>] the keywords for the method, both
    #   required and optional, but excluding variadic keywords.
    # @param variadic_arguments [Symbol] the name of the variadic arguments
    #   parameter, if any.
    # @param variadic_keywords [Symbol] the name of the variadic keywords
    #   parameter, if any.
    def initialize(
      arguments:          [],
      keywords:           [],
      block:              nil,
      variadic_arguments: nil,
      variadic_keywords:  nil
    )
      @arguments          = arguments.map(&:to_sym).freeze
      @block              = block&.to_sym
      @keywords           = Set.new(keywords.map(&:to_sym)).freeze
      @variadic_arguments = variadic_arguments&.to_sym
      @variadic_keywords  = variadic_keywords&.to_sym
    end

    # @return [Hash{Symbol=>Integer}] the named arguments to the method, both
    #   required and optional, but excluding variadic args).
    attr_reader :arguments

    # @return [Symbol, nil] the name of the block parameter, if any.
    attr_reader :block

    # @return [Set<Symbol>] the keywords for the method, both required and
    #   optional, but excluding variadic keywords.
    attr_reader :keywords

    # @return [Symbol] the name of the variadic arguments parameter, if any.
    attr_reader :variadic_arguments

    # @return [Symbol] the name of the variadic keywords parameter, if any.
    attr_reader :variadic_keywords

    # @return [Integer] the number of named arguments.
    def arguments_count
      @arguments_count ||= arguments.size
    end

    # @return [true, false] true if the method has a block parameter; otherwise
    #   false.
    def block?
      !@block.nil?
    end

    # @overload call(*arguments, **keywords, &block)
    #   Maps the given parameters to a Hash of parameter names and values.
    #
    #   @param arguments [Array] the positional parameters to map.
    #   @param keywords [Hash] the keyword parameters to map.
    #   @param block [Proc] the block parameter to map, if any.
    #
    #   @return [Hash{Symbol=>Object}] the mapped parameters.
    def call(*args, **kwargs, &block_arg) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      params = {}
      extras = {}

      arguments.each.with_index { |name, index| params[name] = args[index] }

      if variadic_arguments?
        params[variadic_arguments] = args[arguments_count..] || []
      end

      keywords.each { |name| params[name] = nil }

      kwargs.each do |(name, value)|
        (keywords.include?(name) ? params : extras)[name] = value
      end

      params[variadic_keywords] = extras if variadic_keywords?

      params[block] = block_arg if block?

      params
    end

    # @return [true, false] true if the method has a variadic arguments
    #   parameter; otherwise false.
    def variadic_arguments?
      !@variadic_arguments.nil?
    end

    # @return [true, false] true if the method has a variadic keywords
    #   parameter; otherwise false.
    def variadic_keywords?
      !@variadic_keywords.nil?
    end
  end
end

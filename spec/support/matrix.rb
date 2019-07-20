# frozen_string_literal: true

module Spec
  class Matrix
    def initialize(example_group)
      @example_group = example_group
    end

    attr_reader :example_group

    def evaluate(**scenarios, &block)
      matrix = build_matrix(scenarios)

      matrix.each do |labels:, properties:|
        example_name = generate_example_name(labels)

        example_group.context(example_name).instance_exec(**properties, &block)
      end
    end

    private

    def build_matrix(scenarios)
      return [] if scenarios.empty?

      matrix = [{ labels: [], properties: {} }]

      scenarios.each do |keyword, values|
        matrix =
          expand_scenarios(matrix: matrix, keyword: keyword, values: values)
      end

      matrix
    end

    def expand_scenarios(matrix:, keyword:, values:)
      expanded = []

      matrix.each do |labels:, properties:|
        values.each do |(label, value)|
          expanded << {
            labels:     [*labels, label],
            properties: properties.merge(keyword => value)
          }
        end
      end

      expanded
    end

    def generate_example_name(labels)
      ary = labels.map(&:to_s).reject(&:empty?)

      "with #{tools.array.humanize_list(ary)}"
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end

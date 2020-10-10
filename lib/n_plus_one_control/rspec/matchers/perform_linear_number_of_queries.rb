# frozen_string_literal: true

# rubocop:disable  Metrics/BlockLength
::RSpec::Matchers.define :perform_linear_number_of_queries do |slope: 1|
  supports_block_expectations

  match do |actual, *_args|
    raise ArgumentError, "Block is required" unless actual.is_a? Proc

    raise "Missing tag :n_plus_one" unless
      @matcher_execution_context.respond_to?(:n_plus_one_populate)

    populate = @matcher_execution_context.n_plus_one_populate

    @matcher_execution_context.executor = NPlusOneControl::Executor.new(
      population: populate,
      matching: nil,
      scale_factors: @factors
    )

    @queries = @matcher_execution_context.executor.call(&actual)

    @queries.each_cons(2).all? do |pair|
      scales = pair.map(&:first)
      query_lists = pair.map(&:last)

      actual_slope = (query_lists[1].size - query_lists[0].size) / (scales[1] - scales[0])
      actual_slope <= slope
    end
  end

  match_when_negated do |_actual|
    raise "This matcher doesn't support negation"
  end

  # TODO: failure message for linear queries
  # failure_message { |_actual| NPlusOneControl.failure_message(@queries) }
end
# rubocop:enable  Metrics/BlockLength
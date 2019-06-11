# coding: utf-8

module Evaluation
  module DatumHelper
    def row_class(numbers, ground_truth)
      numbers.include?(ground_truth) ? 'success' : 'danger'
    end

    def span_color(number, ground_truth)
      number == ground_truth ? 'limegreen' : 'gray'
    end
  end
end

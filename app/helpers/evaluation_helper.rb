# coding: utf-8

module EvaluationHelper
  def row_class(numbers, ground_truth)
    numbers.include?(ground_truth) ? 'success' : 'danger'
  end

  def span_color(number, ground_truth)
    number == ground_truth ? 'limegreen' : 'gray'
  end
end

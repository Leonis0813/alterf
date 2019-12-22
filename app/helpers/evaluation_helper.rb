# coding: utf-8

module EvaluationHelper
  def progress(evaluation)
    case evaluation.state
    when 'completed'
      '完了'
    when 'error'
      'エラー'
    else
      if evaluation.data.empty?
        '0%完了'
      else
        completed_data_size = evaluation.data.to_a.count do |datum|
          datum.prediction_results.present?
        end
        "#{(100 * completed_data_size / evaluation.data.size.to_f).round(0)}%完了"
      end
    end
  end

  def row_class(numbers, datum)
    return 'warning' if datum.prediction_results.empty?

    numbers.include?(datum.ground_truth) ? 'success' : 'danger'
  end

  def span_color(number, ground_truth)
    number == ground_truth ? 'limegreen' : 'gray'
  end

  def data_source_option
    {
      'Top20' => 'remote',
      'ファイル' => 'file',
      '直接入力' => 'text',
      'ランダム' => 'random',
    }
  end
end

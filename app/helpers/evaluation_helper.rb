# coding: utf-8

module EvaluationHelper
  def evaluation_table_headers
    [
      {name: '実行開始日時', width: 25},
      {name: 'モデル', width: 20},
      {name: '状態', width: 15},
      {name: '適合率', width: 10},
      {name: '再現率', width: 10},
      {name: 'F値', width: 10},
    ]
  end

  def progress(evaluation)
    case evaluation.state
    when 'completed'
      '完了'
    when 'error'
      'エラー'
    when 'waiting'
      '実行待ち'
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

  def download_button(evaluation)
    return if %w[text file].include?(evaluation.data_source)
    return unless evaluation.state == 'completed'

    link_to(evaluation_download_path(evaluation.evaluation_id), remote: true) do
      content_tag(:button, class: 'btn btn-success') do
        content_tag(:span, nil, class: 'glyphicon glyphicon-download-alt')
      end
    end
  end
end

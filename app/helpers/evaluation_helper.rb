# coding: utf-8

module EvaluationHelper
  def evaluation_table_headers
    [
      {name: '実行開始日時', width: 14},
      {name: 'モデル', width: 15},
      {name: '指定方法', width: 9},
      {name: 'データ数', width: 8},
      {name: '状態', width: 11},
      {name: '適合率', width: 9},
      {name: '再現率', width: 9},
      {name: '特異度', width: 9},
      {name: 'F値', width: 9},
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

  def row_class(state)
    case state
    when 'waiting'
      'cursor-auto'
    when 'processing'
      'warning cursor-pointer'
    when 'completed'
      'success cursor-pointer'
    when 'error'
      'danger cursor-auto'
    end
  end

  def row_title(state)
    %w[processing completed].include?(state) ? '結果を確認' : ''
  end

  def datum_row_class(numbers, datum)
    return 'warning' if datum.prediction_results.empty?

    numbers.include?(datum.ground_truth) ? 'success' : 'danger'
  end

  def span_color(number, ground_truth)
    number == ground_truth ? 'limegreen' : 'gray'
  end

  def evaluation_data_source_option
    {
      'Top20' => 'remote',
      'ファイル' => 'file',
      '直接入力' => 'text',
      'ランダム' => 'random',
    }
  end

  def evaluation_data_download_button(evaluation)
    return if %w[text file].include?(evaluation.data_source)
    return unless evaluation.state == 'completed'

    link_to(evaluation_download_path(evaluation.evaluation_id), remote: true) do
      content_tag(:button, class: 'btn btn-success') do
        content_tag(:span, nil, class: 'glyphicon glyphicon-download-alt')
      end
    end
  end
end

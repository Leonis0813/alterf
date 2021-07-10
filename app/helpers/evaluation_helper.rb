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

  def collapse_params(id, expanded)
    {
      type: 'button',
      'data-bs-toggle' => 'collapse',
      'data-bs-target' => "##{id}",
      'aria-controls' => id,
      'aria-expanded' => expanded,
    }
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
      if evaluation.races.empty?
        '0%完了'
      else
        completed_data_size = evaluation.races.to_a.count do |race|
          race.test_data.present?
        end
        "#{(100 * completed_data_size / evaluation.races.size.to_f).round(0)}%完了"
      end
    end
  end

  def row_class(state)
    case state
    when 'waiting'
      'cursor-auto'
    when 'processing'
      'table-warning cursor-pointer'
    when 'completed'
      'table-success cursor-pointer'
    when 'error'
      'table-danger cursor-auto'
    end
  end

  def row_title(state)
    %w[processing completed].include?(state) ? '結果を確認' : ''
  end

  def race_row_class(numbers, race)
    return 'warning' if race.test_data.empty?

    numbers.include?(race.ground_truth) ? 'success' : 'danger'
  end

  def cell_class(prediction_result, feature_name)
    if feature_name == 'order'
      'table-dark'
    else
      prediction_result ? 'table-success' : 'table-danger'
    end
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
      attribute = {
        class: 'btn btn-success',
        title: '評価レースをダウンロード',
        data: {'bs-toggle' => 'tooltip', 'bs-placement' => 'top'},
      }

      tag.button(attribute) do
        tag.span(class: 'bi bi-download')
      end
    end
  end
end

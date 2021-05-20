# -*- coding: utf-8 -*-

module AnalysisHelper
  def analysis_table_headers
    [
      {name: '実行開始日時', width: 19},
      {name: '指定方法', width: 10},
      {name: '学習データ数', width: 13},
      {name: '特徴量の数', width: 11},
      {name: 'エントリー数', width: 13},
      {name: 'パラメーター', width: 13},
      {name: '状態', width: 11},
    ]
  end

  def analysis_data_source_option
    {
      'ランダム' => 'random',
      'ファイル' => 'file',
    }
  end

  def index_input_common_option(name)
    {id: "input-index-#{name}", class: 'form-control'}
  end

  def parameter_label_option(name)
    {id: "label-index-#{name}", for: "input-index-#{name}", style: 'font-weight: normal'}
  end

  def parameter_input_option(name, parameter = {})
    index_input_common_option(name).merge(
      name: "parameter[#{name}]",
      value: parameter[name],
    ).compact
  end

  def question_sign(param_name)
    content_tag(
      :span,
      nil,
      class: 'glyphicon glyphicon-question-sign', title: question_title[param_name],
    )
  end

  def analysis_result_download_button(analysis)
    return unless analysis.state == 'completed'

    link_to(analysis_download_path(analysis.analysis_id), remote: true) do
      content_tag(:button, class: 'btn btn-light btn-sm') do
        content_tag(:span, nil, class: 'bi bi-download', title: '結果をダウンロード')
      end
    end
#    content_tag(:button, class: 'btn btn-light btn-sm', title: '結果をダウンロード') do
#      content_tag(:span, nil, class: 'bi bi-download')
#    end
  end

  private

  def question_title
    {
      max_depth: '木の深さの最大値',
      max_features: '決定木の生成に使用する素性数の最大値',
      max_leaf_nodes: '葉ノード数の最大値',
      min_samples_leaf: '葉ノードに存在するデータ数の最小値',
      min_samples_split: '中間ノードに存在するデータ数の最小値',
      num_tree: '決定木の数',
    }
  end
end

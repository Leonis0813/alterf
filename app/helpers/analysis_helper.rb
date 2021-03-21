# -*- coding: utf-8 -*-

module AnalysisHelper
  def analysis_table_headers
    [
      {name: '実行開始日時', width: 20},
      {name: '学習データ数', width: 15},
      {name: '特徴量の数', width: 12},
      {name: 'エントリー数', width: 15},
      {name: 'パラメーター', width: 18},
      {name: '状態', width: 10},
    ]
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

    content_tag(:button, class: 'btn btn-default', title: '結果をダウンロード') do
      content_tag(:span, nil, class: 'glyphicon glyphicon-download-alt')
    end
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

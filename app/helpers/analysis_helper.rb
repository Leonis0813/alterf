# -*- coding: utf-8 -*-

module AnalysisHelper
  def analysis_table_headers
    [
      {name: '実行開始日時', width: 25},
      {name: '学習データ数', width: 15},
      {name: '決定木の数', width: 15},
      {name: '特徴量の数', width: 15},
      {name: 'エントリー数', width: 15},
      {name: '状態', width: 15},
    ]
  end
end

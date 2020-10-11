# -*- coding: utf-8 -*-

module AnalysisHelper
  def analysis_table_headers
    [
      {name: '実行開始日時', width: 20},
      {name: '学習データ数', width: 15},
      {name: '特徴量の数', width: 12},
      {name: 'エントリー数', width: 15},
      {name: 'パラメーター', width: 28},
      {name: '状態', width: 10},
    ]
  end
end

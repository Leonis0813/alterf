# coding: utf-8

module ApplicationHelper
  def time_to_string(time)
    time.strftime('%Y/%m/%d %T')
  end

  def state_to_class(state)
    case state
    when 'processing'
      'warning'
    when 'completed'
      'success'
    when 'error'
      'danger'
    end
  end

  def state_to_title(state)
    case state
    when 'processing'
      '実行中'
    when 'completed'
      '完了'
    when 'error'
      'エラー'
    end
  end
end

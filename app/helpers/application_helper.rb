# coding: utf-8

module ApplicationHelper
  def tab_params(id, active)
    {
      class: "nav-link #{active ? 'active' : ''}".strip,
      type: 'button',
      role: 'tab',
      'data-bs-toggle' => 'tab',
      'data-bs-target' => "##{id}",
      'aria-controls' => id,
      'aria-selected' => active,
    }
  end

  def time_to_string(time)
    time&.strftime('%Y/%m/%d %T')
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
    when 'waiting'
      '実行待ち'
    when 'processing'
      '実行中'
    when 'completed'
      '完了'
    when 'error'
      'エラー'
    end
  end
end

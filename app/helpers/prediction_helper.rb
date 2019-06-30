module PredictionHelper
  def link_text(test_data)
    test_data.match(%r{db.netkeiba.com/race/(\d+)/?})[1]
  end

  def number_color(index)
    case index
    when 0
      'orange'
    when 1
      'skyblue'
    when 2
      'magenta'
    else
      'black'
    end
  end
end

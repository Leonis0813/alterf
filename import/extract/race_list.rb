def parse_race_list(html)
  html.scan(%r[.*/race/(\d+)]).flatten
end

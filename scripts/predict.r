library(yaml)

args = commandArgs(trailingOnly=T)
id <- args[1]
model <- args[2]
test_data <- args[3]

config <- yaml.load_file("config/settings.yml")

model_file <- paste("tmp", "files", id, model, sep="/")
load(model_file)

test_data_file <- paste("tmp", "files", id, test_data, sep="/")
data <- yaml.load_file(test_data_file)
data_size <- length(data$entries)

distance <- c(rep(data$distance, data_size))
direction <- c(rep(data$direction, data_size))
if(data$grade == FALSE) {
  data$grade <- "N"
}
grade <- c(rep(data$grade, data_size))
month <- c(rep(data$month, data_size))
place <- c(rep(data$place, data_size))
round <- c(rep(data$round, data_size))
track <- c(rep(data$track, data_size))
weather <- c(rep(data$weather, data_size))

horse_features <- config$prediction$feature$horses
entry_features <- horse_features[-which(horse_features %in% "won")]
entry_features <- c(entry_features, config$prediction$feature$jockeys)

test_data <- as.data.frame(
  t(matrix(unlist(data$entries), length(entry_features), data_size))
)
colnames(test_data) <- entry_features

test_data <- data.frame(
  age = as.integer(test_data$age),
  blank = as.integer(test_data$blank),
  burden_weight = as.numeric(test_data$burden_weight),
  direction = factor(direction, levels = attributes(model)$levels_direction),
  distance = as.integer(distance),
  distance_diff = as.numeric(test_data$distance_diff),
  entry_times = as.integer(test_data$entry_times),
  grade = factor(grade, levels = attributes(model)$levels_grade),
  horse_average_prize_money = as.numeric(test_data$horse_average_prize_money),
  jockey_average_prize_money = as.numeric(test_data$jockey_average_prize_money),
  jockey_win_rate = as.numeric(test_data$jockey_win_rate),
  jockey_win_rate_last_four_races = as.numeric(test_data$jockey_win_rate_last_four_races),
  last_race_order = as.integer(test_data$last_race_order),
  month = as.integer(month),
  number = as.integer(test_data$number),
  place = factor(place, levels = attributes(model)$levels_place),
  rate_within_third = as.numeric(test_data$rate_within_third),
  round = as.integer(round),
  running_style = factor(test_data$running_style, levels = attributes(model)$levels_running_style),
  second_last_race_order = as.integer(test_data$second_last_race_order),
  sex = factor(test_data$sex, levels = attributes(model)$levels_sex),
  track = factor(track, levels = attributes(model)$levels_track),
  weather = factor(weather, levels = attributes(model)$levels_weather),
  weight = as.numeric(test_data$weight),
  weight_diff = as.numeric(test_data$weight_diff),
  weight_per = as.numeric(test_data$weight_per),
  win_times = as.integer(test_data$win_times)
)

library(randomForest)
result <- predict(model, test_data)

for(i in 1:length(result)) {
    write(paste(i, ": ", result[i], sep=""), file=paste("tmp", "files", id, "prediction.yml", sep="/"), append=T)
}

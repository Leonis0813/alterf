library(yaml)

args = commandArgs(trailingOnly=T)
id <- args[1]
model <- args[2]
test_data <- args[3]

model_file <- paste("tmp", "files", id, model, sep="/")
load(model_file)

test_data_file <- paste("tmp", "files", id, test_data, sep="/")
data <- yaml.load_file(test_data_file)
data_size <- length(data$test_data)

distance <- c(rep(data$distance, data_size))
direction <- c(rep(data$direction, data_size))
grade <- c(rep(data$grade, data_size))
place <- c(rep(data$place, data_size))
round <- c(rep(data$round, data_size))
track <- c(rep(data$track, data_size))
weather <- c(rep(data$weather, data_size))

test_data <- as.data.frame(t(matrix(unlist(data$test_data), 5, data_size)))
colnames(test_data) <- c("age", "burden_weight", "number", "weight", "weight_diff")

test_data <- data.frame(
  age=as.integer(test_data$age),
  burden_weight=as.numeric(test_data$burden_weight)
  direction=factor(direction, levels = attributes(model)$levels_direction),
  distance=as.integer(distance),
  grade=factor(grade, levels = attributes(model)$levels_grade),
  number=as.integer(test_data$number),
  place=factor(place, levels = attributes(model)$levels_place),
  round=as.integer(round),
  track=factor(track, levels = attributes(model)$levels_track),
  weather=factor(weather, levels = attributes(model)$levels_weather),
  weight=as.numeric(test_data$weight),
  weight_diff=as.numeric(test_data$weight_diff),
)

library(randomForest)
result <- predict(model, test_data)

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
for(i in 1:length(result)) {
    write(paste(i, ": ", result[i], sep=""), file=paste("tmp", "files", id, "prediction.yml", sep="/"), append=T)
}

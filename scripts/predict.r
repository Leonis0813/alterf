library(yaml)

args = commandArgs(trailingOnly=T)
id <- args[1]
model <- args[2]
test_data <- args[3]

model_file <- paste("tmp", id, model, sep="/")
load(model_file)

test_data_file <- paste("tmp", id, test_data, sep="/")
data <- yaml.load_file(test_data_file)
data_size <- length(data$test_data)

distance <- c(rep(data$distance, data_size))
round <- c(rep(data$round, data_size))
place <- c(rep(data$place, data_size))
direction <- c(rep(data$direction, data_size))
weather <- c(rep(data$weather, data_size))
track <- c(rep(data$track, data_size))

test_data <- as.data.frame(t(matrix(unlist(data$test_data), 4, data_size)))
colnames(test_data) <- c("age", "number", "weight", "burden_weight")

test_data <- data.frame(
  distance=as.integer(distance),
  round=as.integer(round),
  place=factor(place, levels = attributes(model)$levels_place),
  direction=factor(direction, levels = attributes(model)$levels_direction),
  weather=factor(weather, levels = attributes(model)$levels_weather),
  track=factor(track, levels = attributes(model)$levels_track),
  age=as.integer(test_data$age),
  number=as.integer(test_data$number),
  weight=as.numeric(test_data$weight),
  burden_weight=as.numeric(test_data$burden_weight)
)

library(randomForest)
result <- predict(model, test_data)

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
for(i in 1:length(result)) {
    write(paste(i, ": ", result[i], sep=""), file=paste("tmp", id, "prediction.yml", sep="/"), append=T)
}

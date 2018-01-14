library(yaml)

args = commandArgs(trailingOnly=T)
training_file <- args[1]
model_file <- args[2]
race_file <- args[3]

load(model_file)
data <- yaml.load_file(training_file)
unlist_data <- unlist(data$training_data)
data_size <- length(data$training_data)
attribute_size <- length(unlist_data) / data_size
training_data <- matrix(unlist_data, attribute_size, data_size)
rownames(training_data) <- c("age", "direction", "distance", "number", "weight", "place", "round", "track", "weather", "burden_weight", "won")
training_data <- as.data.frame(t(training_data))
training_data <- training_data[,c(-11)]
training_data$age <- as.integer(training_data$age)
training_data$distance <- as.integer(training_data$distance)
training_data$number <- as.integer(training_data$number)
training_data$round <- as.integer(training_data$round)
training_data_size <- data_size

data <- yaml.load_file(race_file)
unlist_data <- unlist(data$test_data)
data_size <- length(data$test_data)
attribute_size <- length(unlist_data) / data_size
test_data <- matrix(unlist_data, attribute_size, data_size)
rownames(test_data) <- c("age", "number", "weight", "burden_weight")
test_data <- as.data.frame(t(test_data))
test_data$distance <- c(rep(data$distance, data_size))
test_data$round <- c(rep(data$round, data_size))
test_data$place <- c(rep(data$place, data_size))
test_data$direction <- c(rep(data$direction, data_size))
test_data$weather <- c(rep(data$weather, data_size))
test_data$track <- c(rep(data$track, data_size))
test_data_size <- data_size

data <- rbind(training_data, test_data)
data$age <- as.integer(data$age)
data$distance <- as.integer(data$distance)
data$number <- as.integer(data$number)
data$round <- as.integer(data$round)
data$place <- as.factor(data$place)
data$direction <- as.factor(data$direction)
data$weather <- as.factor(data$weather)
data$track <- as.factor(data$track)
data$weight <- as.numeric(data$weight)
data$burden_weight <- as.numeric(data$burden_weight)

library(randomForest)
result <- predict(model, data[(training_data_size + 1):(training_data_size + test_data_size),])

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
for(i in 1:length(result)) {
    write(paste(i, ": ", result[i], sep=""), file=paste("scripts/results/prediction_", timestamp, ".txt", sep=""), append=T)
}

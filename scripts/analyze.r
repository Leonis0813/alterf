args = commandArgs(trailingOnly=T)
id <- args[1]
num_training_data <- args[2]
ntree <- as.integer(args[3])
mtry <- as.integer(args[4])

library(yaml)
config <- yaml.load_file("scripts/settings.yml")
library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(
  driver,
  dbname="denebola",
  user=config$mysql$user,
  password=config$mysql$password,
  host=config$mysql$host,
  port=as.integer(config$mysql$port)
)

sql <- "SELECT race_id FROM features WHERE `order` = '1'"
records <- dbGetQuery(dbconnector, sql)

race_ids <- records$race_id
if(length(race_ids) >= as.integer(num_training_data) / 2) {
  race_ids <- sample(race_ids, as.integer(num_training_data) / 2)
}

sql <- paste(
  "SELECT ",
  paste(config$features, collapse=","),
  ", IF(`order` = '1', 1, 0) AS won FROM features WHERE `order` REGEXP '[0-9]+' AND race_id IN (",
  paste(race_ids, collapse = ","),
  ")"
)
training_data <- dbGetQuery(dbconnector, sql)
positive <- training_data[training_data$won==1,]
negative <- training_data[training_data$won==0,]
negative <- negative[sample(nrow(negative), nrow(positive)), ]
training_data <- rbind(positive, negative)

training_data$direction <- as.factor(training_data$direction)
training_data$grade <- as.factor(training_data$grade)
training_data$place <- as.factor(training_data$place)
training_data$track <- as.factor(training_data$track)
training_data$weather <- as.factor(training_data$weather)
training_data$won <- as.factor(training_data$won)

library(randomForest)
model <- randomForest(won~., data=training_data, ntree=ntree, mtry=mtry, na.action="na.omit")
attributes(model)$levels_direction <- levels(training_data$direction)
attributes(model)$levels_grade <- levels(training_data$grade)
attributes(model)$levels_place <- levels(training_data$place)
attributes(model)$levels_track <- levels(training_data$track)
attributes(model)$levels_weather <- levels(training_data$weather)

filename <- paste("tmp", "files", id, "analysis.yml", sep="/")
write(paste("num_of_training_data:", num_training_data), file=filename)
write(paste("ntree:", ntree), file=filename, append=T)
write(paste("mtry:", mtry), file=filename, append=T)
write("training_data:", file=filename, append=T)
attributes <- paste(
  training_data$age,
  training_data$burden_weight,
  training_data$direction,
  training_data$distance,
  training_data$grade,
  training_data$number,
  training_data$place,
  training_data$round,
  training_data$track,
  training_data$weather,
  training_data$weight,
  training_data$weight_diff,
  training_data$won,
  sep=", "
)
write(paste("  - [", attributes, "]", sep=""), file=filename, append=T)
save(model, file=paste("tmp", "files", id, "model.rf", sep="/"))

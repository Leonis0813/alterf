args = commandArgs(trailingOnly=T)
id <- args[1]
num_training_data <- args[2]
ntree <- as.integer(args[3])
mtry <- as.integer(args[4])

library(yaml)
config <- yaml.load_file("scripts/settings.yml")

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="alterf", user=config$mysql$user, password=config$mysql$password, host=config$mysql$host, port=as.integer(config$mysql$port))

sql <- paste("SELECT age, direction, distance, number, weight, place, round, track, weather, burden_weight, IF(`order` = '1', 1, 0) AS won FROM training_data WHERE `order` REGEXP '[0-9]+' LIMIT", num_training_data)
training_data <- dbGetQuery(dbconnector, sql)
training_data$direction <- as.factor(training_data$direction)
training_data$place <- as.factor(training_data$place)
training_data$track <- as.factor(training_data$track)
training_data$weather <- as.factor(training_data$weather)
training_data$won <- as.factor(training_data$won)

library(randomForest)
model <- randomForest(won~., data=training_data, ntree=ntree, mtry=mtry, na.action="na.omit")

filename <- paste("results/analysis", id, sep="_")
write(paste("num_of_training_data:", num_training_data), file=paste(filename, "yml", sep="."))
write(paste("ntree:", ntree), file=paste(filename, "yml", sep="."), append=T)
write(paste("mtry:", mtry), file=paste(filename, "yml", sep="."), append=T)
write("training_data:", file=paste(filename, "yml", sep="."), append=T)
attributes <- paste(training_data$age, training_data$direction, training_data$distance, training_data$number, training_data$weight, training_data$place, training_data$round, training_data$track, training_data$weather, training_data$burden_weight, training_data$won, sep=", ")
write(paste("  - [", attributes, "]", sep=""), file=paste(filename, "yml", sep="."), append=T)
save(model, file=paste("results/", id, ".rf", sep=""))

args = commandArgs(trailingOnly=T)
num_training_data <- args[1]
ntree <- as.integer(args[2])
mtry <- as.integer(args[3])

library(yaml)
config <- yaml.load_file("analyze/settings.yml")

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="alterf", user=config$mysql$user, password=config$mysql$password, host=config$mysql$host, port=as.integer(config$mysql$port))

sql <- paste("SELECT distance, round, number, bracket, age, burden_weight, weight, IF(`order` = '1', 1, 0) AS won FROM training_data WHERE `order` REGEXP '[0-9]+' LIMIT", num_training_data)
training_data <- dbGetQuery(dbconnector, sql)
training_data$won <- as.factor(training_data$won)

library(randomForest)
model <- randomForest(won~., data=training_data, ntree=ntree, mtry=mtry)

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
filename <- paste("results/", paste(timestamp, num_training_data, ntree, mtry, sep="_"), sep="")
write(paste("num_of_training_data:", num_training_data), file=paste(filename, "yml", sep="."))
write(paste("ntree:", ntree), file=paste(filename, "yml", sep="."), append=T)
write(paste("mtry:", mtry), file=paste(filename, "yml", sep="."), append=T)
write("training_data:", file=paste(filename, "yml", sep="."), append=T)
attributes <- paste(training_data$distance, training_data$round, training_data$number, training_data$bracket, training_data$age, training_data$burden_weight, training_data$weight, training_data$won, sep=", ")
write(paste("  - [", attributes, "]", sep=""), file=paste(filename, "yml", sep="."), append=T)
save(model, file=paste("results/", timestamp, ".rf", sep=""))

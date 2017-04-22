args = commandArgs(trailingOnly=T)
num_training_data <- args[1]
ntree <- as.integer(args[2])
mtry <- as.integer(args[3])

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="alterf", user="root", password="7QiSlC?4", host="160.16.66.112", port=3306)

training_data <- dbGetQuery(dbconnector, paste("SELECT distance, round, number, bracket, age, burden_weight, weight, IF(`order` = '1', 1, 0) AS won FROM training_data WHERE `order` REGEXP '[0-9]+' LIMIT", num_training_data))
training_data$won <- as.factor(training_data$won)

library(randomForest)
model <- randomForest(won~., data=training_data, ntree=ntree, mtry=mtry)

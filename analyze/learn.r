args = commandArgs(trailingOnly=T)
num_training_data <- args[1]
ntree <- args[2]
mtry <- args[3]

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="alterf", user="root", password="7QiSlC?4", host="160.16.66.112", port=3306)

training_data <- dbGetQuery(dbconnector, paste("SELECT distance, round, number, bracket, age, burden_weight, weight, `order` FROM training_data WHERE `order` REGEXP '[0-9]+' LIMIT ", num_training_data))
summary(training_data)
mode(training_data$order) <- "integer"

library(randomForest)
model <- randomForest(formula=order~., data=training_data, ntree=as.integer(ntree), mtry=as.integer(mtry))

args = commandArgs(trailingOnly=T)
num_training_data <- args[1]

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="alterf", user="root", password="7QiSlC?4", host="160.16.66.112", port=3306)

training_data <- dbGetQuery(dbconnector, paste("SELECT * FROM training_data LIMIT ", num_training_data))

library(yaml)

args = commandArgs(trailingOnly=T)
model_file <- args[1]
race_file <- args[2]

load(model_file)
test_data <- yaml.load_file(race_file)

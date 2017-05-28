library(yaml)

args = commandArgs(trailingOnly=T)
model_file <- args[1]
race_file <- args[2]

load(model_file)
test_data <- yaml.load_file(race_file)

entries <- unlist(test_data$test_data)
entry_size <- length(test_data$test_data)
attribute_size <- length(entries) / entry_size

entries <- matrix(entries, attribute_size, entry_size)
rownames(entries) <- c("number", "bracket", "age", "burden_weight", "weight")
entries <- as.data.frame(t(entries))
entries$distance <- c(rep(test_data$distance, entry_size))
entries$round <- c(rep(test_data$round, entry_size))

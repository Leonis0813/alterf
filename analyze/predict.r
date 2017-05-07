args = commandArgs(trailingOnly=T)
model_file <- args[1]
race_file <- args[2]

load(paste("output/", model_file, sep=""))

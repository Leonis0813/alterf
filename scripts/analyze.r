args = commandArgs(trailingOnly=T)
id <- args[1]
num_training_data <- args[2]
ntree <- as.integer(args[3])

library(yaml)
config <- yaml.load_file("config/settings.yml")

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(
  driver,
  dbname = config$mysql$database,
  user = config$mysql$user,
  password = config$mysql$password,
  host = config$mysql$host,
  port = config$mysql$port
)

sql <- "SELECT race_id FROM features WHERE won = 1"
records <- dbGetQuery(dbconnector, sql)

sql <- "desc features"
description <- dbGetQuery(dbconnector, sql)

race_ids <- records$race_id
if(length(race_ids) >= as.integer(num_training_data) / 2) {
  race_ids <- sample(race_ids, as.integer(num_training_data) / 2)
}

not_feature_names <- c("id", "horse_id", "created_at", "updated_at")
features <- description[-which(description$Field %in% not_feature_names),]

sql <- paste(
  "SELECT ",
  paste(features$Field, collapse=","),
  " FROM features WHERE race_id IN (",
  paste(race_ids, collapse = ","),
  ")"
)
records <- dbGetQuery(dbconnector, sql)

for(i in 1:nrow(features)) {
  feature_name <- features[i, "Field"]

  if(grepl("varchar", features[i, "Type"]) || feature_name == "won") {
    records[, feature_name] <- as.factor(records[, feature_name])
  }
}

splited_data <- split(records, records$race_id)
scaled_data <- unsplit(
  lapply(splited_data,
    function(rw) {
      data.frame(
        won = rw$won,
        age = rw$age,
        blank = rw$blank,
        direction = rw$direction,
        distance = rw$distance,
        distance_diff = rw$distance_diff,
        entry_times = rw$entry_times,
        grade = rw$grade,
        jockey_average_prize_money = rw$jockey_average_prize_money,
        jockey_win_rate = rw$jockey_win_rate,
        jockey_win_rate_last_four_races = rw$jockey_win_rate_last_four_races,
        last_race_order = rw$last_race_order,
        month = rw$month,
        number = rw$number,
        place = rw$place,
        round = rw$round,
        running_style = rw$running_style,
        second_last_race_order = rw$second_last_race_order,
        sex = rw$sex,
        track = rw$track,
        weather = rw$weather,
        scale(rw[,config$analysis$racewise_features])
      )
    }
  ),
  records$race_id
)

scaled_data[is.nan(scaled_data$burden_weight),]$burden_weight <- 0

positive <- scaled_data[scaled_data$won==1,]
negative <- scaled_data[scaled_data$won==0,]
negative <- negative[sample(nrow(negative), nrow(positive)), ]
training_data <- rbind(positive, negative)

library(randomForest)
model <- tuneRF(
  x=training_data[, colnames(training_data) != "won"],
  y=training_data$won,
  ntreeTry=ntree,
  doBest=T
)

for(i in 1:nrow(features)) {
  feature_name <- features[i, "Field"]

  if(grepl("varchar", features[i, "Type"]) && feature_name != "race_id") {
    text <- paste(
      "attributes(model)$levels_",
      feature_name,
      " <- levels(training_data$",
      feature_name,
      ")",
      sep=""
    )
    eval(parse(text=text))
  }
}

filename <- paste("tmp", "files", id, "analysis.yml", sep="/")
write(paste("num of races:", num_training_data), file=filename)
write("num of features:", file=filename, append=T)
write(paste("  positive:", nrow(positive)), file=filename, append=T)
write(paste("  negative:", nrow(negative)), file=filename, append=T)
write(paste("ntree:", ntree), file=filename, append=T)
write(paste("mtry:", model$mtry), file=filename, append=T)
write("levels:", file=filename, append=T)
for(i in 1:nrow(features)) {
  feature_name <- features[i, "Field"]

  if(grepl("varchar", features[i, "Type"]) && feature_name != "race_id") {
    text <- paste("attributes(model)$levels_", feature_name, sep="")
    levels <- paste(eval(parse(text=text)), collapse=", ")
    write(paste("  ", feature_name, ": [", levels, "]", sep=""), file=filename, append=T)
  }
}
write("importance:", file=filename, append=T)
for(i in 1:nrow(model$importance)) {
  write(paste("  ", rownames(model$importance)[i], ": ", model$importance[i], sep=""), file=filename, append=T)
}
save(model, file=paste("tmp", "files", id, "model.rf", sep="/"))

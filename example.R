library(Boruta)
library(ggplot2)
library(lubridate)
library(randomForest)
library(readr)

set.seed(1)

train <- read_csv("train.csv")
test  <- read_csv("test.csv")

add_features <- function (data) {
  data$CityGroup <- as.factor(data[["City Group"]])
  data$OpenDate <- mdy(data[["Open Date"]])
  data$YearsSince1900 <- as.numeric(data$OpenDate-mdy("01/01/1900"), units="days")/365
  return(data)
}

features <- c(names(train)[c(-1, -2, -3, -4, -5, -43)], "CityGroup", "YearsSince1900")

train <- add_features(train)
test  <- add_features(test)
train$Revenue <- train$revenue / 1e6
train$LogRevenue <- log(train$revenue)

boruta <- Boruta(train[,features], train$LogRevenue, doTrace=2)

important_features <- features[boruta$finalDecision!="Rejected"]
rf <- randomForest(train[,important_features], train$LogRevenue, importance=TRUE)

submission <- data.frame(Id=test$Id)
submission$Prediction <- exp(predict(rf, test[,important_features]))

write_csv(submission, "1_boruta_random_forest_benchmark.csv")

imp <- importance(rf, type=1)
featureImportance <- data.frame(Feature=row.names(imp), Importance=imp[,1])

p <- ggplot(featureImportance, aes(x=reorder(Feature, Importance), y=Importance)) +
  geom_bar(stat="identity", fill="#53cfff") +
  coord_flip() + 
  theme_light(base_size=20) +
  xlab("Importance") +
  ylab("") + 
  ggtitle("Random Forest Feature Importance\n") +
  theme(plot.title=element_text(size=18))

ggsave("2_feature_importance.png", p)
Originaldata <- read.csv("train.csv", fileEncoding = "UTF-8")
data <- Originaldata[, -1]
data$Open.Date <- as.Date(data$Open.Date, "%m/%d/%Y")

#find out the relationship of opendate&revenue and citytype&revenue
library(ggplot2)
ggplot() + geom_point(data = data[data$City.Group == "Big Cities", ], mapping = aes(as.Date("01/01/2015") - Open.Date, y = revenue)) + geom_point(data = data[data$City.Group != "Big Cities", ], mapping = aes(x = as.Date("01/01/2015") - Open.Date, y = revenue), shape = 3)

#delete fisrt 2 columns in "data" and combine "opendays" (since 01/01/2015) comlumn with it.
dataset <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - data$Open.Date, data[, -c(1:2)])
colnames(dataset)[1] <- "opendays"

#make sure that P1 ~ P37 have numeric values
dataset[, c(4:40)] <- lapply(dataset[, c(4:40)], as.numeric)
#make sure that column Type are factors 
dataset$Type <- factor(dataset$Type, levels = c("DT", "FC", "IL", "MB")) #there is MB in the test dataset so we need to add "MB" into levels

#boxplot of citygroup and revenue
ggplot(data = dataset) + geom_boxplot(mapping = aes(x = City.Group, y = revenue)) 
+ geom_boxplot(mapping = aes(x = "Total", y = revenue))

#delete revenue outliers in the dataset
Q3 <- quantile(dataset$revenue, probs = 0.75)
Q1 <- quantile(dataset$revenue, probs = 0.25)
IQR <- Q3 - Q1
outliers <- Q3 + 1.5 * IQR
dataset <- dataset[dataset$revenue < outliers, ]

#divide into training and validation dataset
set.seed(1)
train.index <- sample(c(1:dim(dataset)[1]), dim(dataset)[1] * 0.6)
valid.index <- setdiff(c(1:dim(dataset)[1]), train.index)
train.df <- dataset[train.index, ]
valid.df <- dataset[valid.index, ]

#perform random forest on everything
library(randomForest)
rf <- randomForest(revenue ~., data = train.df, ntree = 600, importance = TRUE)
plot(rf)

#variable importance plot
varImpPlot(rf)

#predict training and validation dataset and compute MSE
library(MLmetrics)
valid.pred <- predict(rf, valid.df[, -41])
MSE(valid.pred, valid.df[, 41])
train.pred <- predict(rf, train.df[, -41])
MSE(train.pred, train.df[, 41])

#read test dataset
test <- read.csv("test.csv", fileEncoding = "UTF-8")
test$Open.Date <- as.Date(test$Open.Date, "%m/%d/%Y")
test.df <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - test$Open.Date, test[, -c(1:3)])
colnames(test.df)[1] <- "opendays"
test.df[, c(4:40)] <- lapply(test.df[, c(4:40)], as.numeric)

#predict on the test dataset
test.pred <- predict(rf, test.df, type = "response")
final = data.frame(ID = test$Id, Prediction = test.pred)
write.csv(final, "skj_predict.csv", row.names = FALSE)


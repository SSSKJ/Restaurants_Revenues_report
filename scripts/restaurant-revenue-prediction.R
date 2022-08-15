library(openxlsx)
library(factoextra)
library(FactoMineR)
library(psych)
library(nnet)
library(gmodels)
library(caret)
library(xts)
library(class)
library(caret)
library(randomForest)
library(party)
library(xgboost)
library(DiagrammeR)

Originaldata <- read.csv("train.csv", fileEncoding = "UTF-8")
data <- Originaldata[, -1]
# pca <- PCA(data[, c(5:37)], graph = T)

MSE <- function(pred, real) {return(mean((pred - real)^2))}


# var <- get_pca_var(pca)
# get_eig(pca)
# fviz_screeplot(pca, addlabels = TRUE, ylim = c(0, 60))

city.type <- class.ind(data$City.Group)
dataset <- data.frame(ifbigcity = city.type[, 1])

restaurant.type <- class.ind(data$Type)
colnames(restaurant.type)
dataset$dt <- restaurant.type[, 1]
dataset$fc <- restaurant.type[, 2]

data$Open.Date <- as.Date(data$Open.Date, "%m/%d/%Y")
# time.series <- as.xts(data$revenue, data$Open.Date)

ggplot() + geom_point(data = data[data$City.Group == "Big Cities", ], mapping = aes(as.Date("01/01/2015") - Open.Date, y = revenue)) + geom_point(data = data[data$City.Group != "Big Cities", ], mapping = aes(x = as.Date("01/01/2015") - Open.Date, y = revenue), shape = 3)
# fa.parallel(data[, c(5:37)], fa = "pc", n.iter = 100)
# pc <- principal(data[, c(5:37)], nfactors = 3, scores = TRUE)

# dataset <- cbind(dataset, pc$scores, data$revenue)

dataset <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - data$Open.Date, dataset, data[, c(5:42)])
# dataset <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - data$Open.Date, data[, -c(1:2)])
colnames(dataset)[1] <- "opendays"
# dataset[, c(4:40)] <- lapply(dataset[, c(4:40)], as.numeric)
# dataset$Type <- factor(dataset$Type, levels = c("DT", "FC", "IL", "MB"))

ggplot(data = data) + geom_boxplot(mapping = aes(x = City.Group, y = revenue)) + geom_boxplot(mapping = aes(x = "Total", y = revenue))

Q3 <- quantile(dataset$revenue, probs = 0.75)
Q1 <- quantile(dataset$revenue, probs = 0.25)
IQR <- Q3 - Q1

outliers <- Q3 + 1.5 * IQR

# dataset <- dataset[dataset$revenue < outliers, ]

# method.knn.model <- knnreg(x = dataset[, -7], y = dataset[, 7], k = 10)
# method.knn.pred <- predict(method.knn.model, dataset[, -7])
# MSE(method.knn.pred, dataset[, 7])

set.seed(1)
train.index <- sample(c(1:dim(dataset)[1]), dim(dataset)[1] * 0.6)
valid.index <- setdiff(c(1:dim(dataset)[1]), train.index)

dataset$opendays <- as.numeric(dataset$opendays)
train.df <- dataset[train.index, ]
valid.df <- dataset[valid.index, ]

# random forest
# rf <- randomForest(revenue ~., data = train.df, ntree = 600, importance = TRUE)

# xgboosting
model <- xgboost(data = as.matrix(train.df[, -42]), label = train.df[, 42], nrounds = 1000, max_depth = 4, eta = 0.1, early_stopping_rounds = 10)
m <- xgb.dump(model, with_stats=T)
names <- dimnames(data.matrix(dataset[,-42]))[[2]]
importance_matrix <- xgb.importance(names, model = model)
xgb.plot.importance(importance_matrix)
xgb.plot.tree(model = model, trees = 0)
xgb.plot.tree(model = model, trees = 1)
xgb.plot.tree(model = model, trees = 2)


pred <- predict(model, as.matrix(valid.df[, -42]))
MSE(pred, valid.df[, 42])


# varImpPlot(rf)
# 
# plot(rf)
# valid.pred <- predict(rf, valid.df[, -41])
# MSE(valid.pred, valid.df[, 41])
# 
# train.pred <- predict(rf, train.df[, -41])
# MSE(train.pred, train.df[, 41])
# 
# rf <- randomForest(revenue ~., data = dataset, ntree = 600, importance = TRUE)

test <- read.csv("test.csv", fileEncoding = "UTF-8")
test$Open.Date <- as.Date(test$Open.Date, "%m/%d/%Y")

city.type <- class.ind(test$City.Group)
test.df <- data.frame(ifbigcity = city.type[, 1])

restaurant.type <- class.ind(test$Type)
colnames(restaurant.type)
test.df$dt <- restaurant.type[, 1]
test.df$fc <- restaurant.type[, 2]
# test.df <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - test$Open.Date, test[, -c(1:3)])
test.df <- cbind(as.Date("01/01/2015", "%m/%d/%Y") - test$Open.Date, test.df, test[, c(6:42)])
colnames(test.df)[1] <- "opendays"
test.df$opendays <- as.numeric(test.df$opendays)
# test.df[, c(4:40)] <- lapply(test.df[, c(4:40)], as.numeric)

# test.pred <- predict(rf, test.df, type = "response")
test.pred <- predict(model, as.matrix(test.df))
final = data.frame(ID = test$Id, Prediction = test.pred)
write.csv(final, "skj_predict.csv", row.names = FALSE)

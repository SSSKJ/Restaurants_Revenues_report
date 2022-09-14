# Restaurants Revenues report

## Description

This is a Data Mining project for **IE 7275 Data Mining in Engineering** in Northeastern University. In this project,  we obtained the dataset of TFI company’s restaurants located at 100000 sites around the world from. We preprocessed the data by deleting and converting some variables. The goal of our case study is to build regression models such as random forest and XGBoost, use them to predict new restaurants revenues in order to decide where to open new sites. In the end, we find out that random forest model has a better performance.  **You can read the report about this project in the report file for more details. The code is in scripts file for data visualization, analyzing and modeling **.

## How to Run

Run ./scriRESTAURANT REVENUE PREDICTION - GROUP 2.R with R studio

## Background and Introduction

With over 1,200 quick service restaurants across the globe, TFI is the company behind some of the world's most well-known brands: Burger King, Sbarro, Popeyes, Usta Donerci, and Arby’s. They employ over 20,000 people in Europe and Asia and make significant daily investments in developing new restaurant sites. Right now, deciding when and where to open new restaurants is largely a subjective process based on the personal judgement and experience of development teams. This subjective data is difficult to accurately extrapolate across geographies and cultures. New restaurant sites take large investments of time and capital to get up and running. When the wrong location for a restaurant brand is chosen, the site closes within 18 months and operating losses are incurred. Finding a mathematical model to increase the effectiveness of investments in new restaurant sites would allow TFI to invest more in other important business areas, like sustainability, innovation, and training for new employees. Using demographic, real estate, and commercial data. The goal of our study is to build a regression method and use it to predict new restaurants revenues in order to decide where to open new sites. The possible solutions are xgboost and random forest.

## Summary

In this case study, we preprocessed our data by converting data types, deleting outliers, visualizing data and selecting variables. Then we split the data into training set and validation set. We use the training data to build two regression models: random forest model and XGBoost model. Then we use validation set to evaluate our model by checking the MAE and RMSE. Along with the prediction we made on the testing dataset and Kaggle score we obtain, we made a conclusion that random forest method is optimal for our case study.


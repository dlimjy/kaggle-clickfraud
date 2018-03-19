library(dplyr)
library(readr)
library(lubridate)

train <- read_csv("train.csv")

# Feature eng
train$click_time <- train$click_time %>% ymd_hms # convert from char to lubridate date time
train$attributed_time <- NULL

train$hr_of_day <- train$click_time %>% hour # hour of day
train$click_date <- train$click_date %>% day

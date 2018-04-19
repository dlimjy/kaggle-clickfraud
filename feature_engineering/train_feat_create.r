library(dplyr)
library(h2o)
library(lubridate)
library(data.table)
library(ROCR)
library(randomForest)

train <- fread("train.csv")

# Feature eng

# Time stuff
train$click_time <- train$click_time %>% ymd_hms # convert from char to lubridate date time
train$attributed_time <- NULL

train$hr_of_day <- train$click_time %>% hour # hour of day
hr_resp_tab <- table(train$hr_of_day, train$is_attributed) %>% as.data.frame.matrix
names(hr_resp_tab) <- c("no_dl", "dl")
hr_resp_tab %>% mutate(rate = dl/(dl + no_dl))

# App stuff
app_count <- table(train$app) %>% as.data.frame
names(app_count) <- c("app", "freq")

# OS stuff
os_count <- train$os %>% table %>% as.data.frame %>% arrange(desc(Freq))
names(os_count) <- c("os", "freq")
train$os_group <- ifelse(train$os == 19, "o19", ifelse(train$os == 13, "o13", ifelse(train$os == 17, "o17", ifelse(train$os == 18, "o18", ifelse(train$os == 22, "o22", "other"))))) 

# Device stuff
device_count <- train$device %>% table %>% as.data.frame %>% arrange(desc(Freq))
names(device_count) <- c("device", "freq")
train$device_group <- ifelse(train$device == 1, "d1", ifelse(train$device == 2, "d2", ifelse(train$device == 0, "d0", ifelse(train$device == 3032, "d3032", ifelse(train$device == 3543, "d3543", ifelse(train$device == 3866, "d3866", "other"))))))

# Channel stuff
channel_count <- train$channel %>% table %>% as.data.frame %>% arrange(desc(Freq))
names(channel_count) <- c("channel", "freq")

# Convert char to factor
train$app_f <- train$app %>% as.factor
train$device_f <- train$device %>% as.factor
train$os_f <- train$os %>% as.factor
train$channel_f <- train$channel %>% as.factor
train$is_attributed <- train$is_attributed %>% factor(levels = unique(train$is_attributed))

# Multiple groupbys to obtain counts
tot_by_ip <- train %>% group_by(ip_f) %>% summarise(tot_by_ip = n())
tot_by_ip_os <- train %>% group_by(ip_f, os_f) %>% summarise(tot_by_ip_os = n())
tot_by_ip_app <- train %>% group_by(ip_f, app_f) %>% summarise(tot_by_ip_app = n())
tot_by_ip_dev <- train %>% group_by(ip_f, device_f) %>% summarise(tot_by_ip_dev = n())
tot_by_ip_chan <- train %>% group_by(ip_f, channel_f) %>% summarise(tot_by_ip_chan = n())

# Join to existing data 184903890
train <- train %>% left_join(tot_by_ip, by = "ip_f") %>% left_join(tot_by_ip_os, by = c("ip_f", "os_f")) %>% left_join(tot_by_ip_app, by = c("ip_f", "app_f")) %>% left_join(tot_by_ip_dev, by = c("ip_f", "device_f")) %>% left_join(tot_by_ip_chan, by = c("ip_f", "channel_f"))

h2o.init(ip = "172.31.9.47", port = 54321)

# Split data to train and validation
smp_size <- floor(0.8 * nrow(train))
set.seed(1234)
train_ind <- sample(seq_len(nrow(train)), size = smp_size)

trainset <- train[train_ind, ]
validset <- train[-train_ind, ]

# Undersample
trainset_1 <- trainset %>% dplyr::filter(is_attributed == 1) %>% dplyr::sample_frac(size = 0.1)
trainset_0 <- trainset %>% dplyr::filter(is_attributed == 0) %>% dplyr::sample_n(size =  9 * nrow(trainset_1))
trainset_smp <- rbind(trainset_1, trainset_0)

# trainset.hex <- as.h2o(trainset, destination_frame = "trainset.hex")
# validset.hex <- as.h2o(validset, destination_frame = "validset.hex")

### GBM attempt
glm1 <- glm(is_attributed ~ hr_of_day + ip_f + app_f + device_f + os_f + channel_f + tot_by_ip + tot_by_ip_os + tot_by_ip_app + tot_by_ip_dev + tot_by_ip_chan, data = trainset_smp, family = binomial) 
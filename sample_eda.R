setwd("E:/Analytics/Kaggle/Click Fraud/Data")

# Read in data
smp <- fread("train_sample.csv") %>% as.tibble

# Adjust datetimes, read in as chr
smp$click_time <- smp$click_time %>% ymd_hms
smp$attributed_time <- smp$attributed_time %>% ymd_hms

# Feature generation
smp$hr_of_day <- smp$click_time %>% hour # generate hour of day


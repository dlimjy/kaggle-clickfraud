setwd("E:/Analytics/Kaggle/Click Fraud/Data")

# Read in data
smp <- fread("train_sample.csv") %>% as.tibble

# Adjust datetimes, read in as chr
smp$click_time <- smp$click_time %>% ymd_hms
smp$attributed_time <- smp$attributed_time %>% ymd_hms

# Attr time seems pointless, remove
smp$attributed_time <- NULL

# Feature generation
smp$hr_of_day <- smp$click_time %>% hour # generate hour of day
smp$click_date <- smp$click_time %>% day

# Factors
smp$ip_f <- smp$ip %>% as.factor
smp$app_f <- smp$ip %>% as.factor
smp$device_f <- smp$ip %>% as.factor
smp$os_f <- smp$os %>% as.factor
smp$channel_f <- smp$channel %>% as.factor
smp$is_attributed <- smp$is_attributed %>% factor(levels = unique(smp$is_attributed))

# Undersample
smp_1 <- smp %>% filter(is_attributed == 1)
smp_0 <- smp %>% filter(is_attributed == 0) %>% sample_n((nrow(smp_1) * 19))
smp_us <- rbind(smp_1, smp_0)

# smp_us %>% write_csv(paste0(Sys.Date(), "_smp_us.csv"))

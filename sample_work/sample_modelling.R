## Run packages-setup.R first

# Read in sample
# smp_us <- read_csv("2018-03-17_smp_us.csv)

## Try Rpart first
rp1 <- rpart(is_attributed ~ hr_of_day + click_date + ip_f + app_f + device_f + os_f + channel_f, data = smp_us)
plot(rp1)

rp1_pred <- rp1 %>% predict(newdata = smp_us) %>% as.data.frame
rp1_pred$actual <- smp_us$is_attributed

# Confusion matrix, set at >= 0.5
table(rp1_pred$`1` > 0.5, rp1_pred$actual)

# ROC
rp1_perf <- prediction(rp1_pred$`1`, rp1_pred$actual)
rp1_roc <- performance(rp1_perf, measure = "tpr", x.measure = "fpr")
plot(rp1_roc)
abline(a = 0, b = 1)

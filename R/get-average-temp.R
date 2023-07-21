#########################################################################################
# Takes in and processes historical monthly average temperature for US counties from NOAA
# Processed data feeds into reproduction number estimate
#########################################################################################

library(tidyverse)
library(r2r)

# Load raw data file
avg_temp <- read.table(file = "raw-data/climdiv-tmpccy-v1.0.0-20230707.txt", header = FALSE, colClasses = c(V1 = "character"))

# Rearranging columns and filtering to data for past 10 years
avg_temp %>% 
  transform(FIPS_NOAA = substr(V1, 1, 5), Year = substr(V1, 8, 11)) %>% 
  select(-V1) %>% 
  select(FIPS_NOAA,Year,everything()) -> avg_temp 
  # filter(Year>2012) -> avg_temp

# Rename column headers
colnames(avg_temp) <- c('FIPS_NOAA','Year','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

# State codes used in NOAA dataset are different from ANSI state codes
# Adjust FIPS codes to match US Census Bureau (ANSI standard)

NOAA <- c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","50")
ANSI <- c("01","04","05","06","08","09","10","12","13","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56","02")
NOAA_to_ANSI <- as.list(ANSI)
names(NOAA_to_ANSI) <- NOAA

NOAA_state_codes <- substr(avg_temp$FIPS_NOAA,1,2)
county_codes <- substr(avg_temp$FIPS_NOAA,3,5)
avg_temp$ANSI_state_code <- NOAA_to_ANSI[match(NOAA_state_codes, names(NOAA_to_ANSI))]
avg_temp$FIPS <- paste(avg_temp$ANSI_state_code,county_codes,sep = "")
avg_temp %>% 
  select(-c(ANSI_state_code,FIPS_NOAA)) %>%
  select(FIPS,everything()) -> avg_temp

# Old code:
# # NOAA_to_ANSI <- hashmap()
# NOAA_to_ANSI[c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","50")] <-
#   c("01","04","05","06","08","09","10","12","13","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56","02")
# 
# fips_col_len <- length(avg_temp$FIPS)
# for (i in 1:fips_col_len) {
#   NOAA_state_code <- substr(avg_temp$FIPS[i],1,2)
#   if (NOAA_state_code == "01") {
#     next
#   }
#   substr(avg_temp$FIPS[i],1,2) <- NOAA_to_ANSI[[NOAA_state_code]]
# }

# Writing data to csv file
write.csv(avg_temp, "processed-data/county-average-temps.csv", row.names=FALSE)
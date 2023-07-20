################################################################################################
# Processes NOAA temperature data to extract max temperature of warmest month for each US county
# Processed data feeds into importation risk model
################################################################################################

library(tidyverse)
library(r2r)

# Load raw data file
monthly_max_temp <- read.table(file = "raw-data/climdiv-tmaxcy-v1.0.0-20230707.txt", header = FALSE, colClasses = c(V1 = "character"))

# Rearranging columns and filtering to data for 2016 and 2017
monthly_max_temp %>% 
  transform(FIPS = substr(V1, 1, 5), Year = substr(V1, 8, 11)) %>% 
  select(-V1) %>% 
  select(FIPS,Year,everything()) %>% 
  filter(Year==2016 | Year==2017) -> monthly_max_temp

# Rename column headers
colnames(monthly_max_temp) <- c('FIPS','Year','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

# State codes used in NOAA dataset are different from ANSI state codes
# Adjust FIPS codes to match US Census Bureau (ANSI standard)
NOAA_to_ANSI <- hashmap()
NOAA_to_ANSI[c("02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","50")] <-
  c("04","05","06","08","09","10","12","13","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56","02")

fips_col_len <- length(monthly_max_temp$FIPS)
for (i in 1:fips_col_len) {
  NOAA_state_code <- substr(monthly_max_temp$FIPS[i],1,2)
  if (NOAA_state_code == "01") {
    next
  }
  substr(monthly_max_temp$FIPS[i],1,2) <- NOAA_to_ANSI[[NOAA_state_code]]
}

# Get warmest month of each year for each county and get max temperature of that month
Year = monthly_max_temp$Year
FIPS = monthly_max_temp$FIPS
monthly_max_temp <- monthly_max_temp %>% select(-c(FIPS,Year))
max_temp <- do.call(pmax,monthly_max_temp)
warmest_month <- colnames(monthly_max_temp)[max.col(monthly_max_temp)]
warmest_month_data <- data.frame(FIPS, Year, warmest_month, max_temp)

# Writing data to csv file
write.csv(warmest_month_data, "processed-data/county-warmest-month.csv", row.names=FALSE)
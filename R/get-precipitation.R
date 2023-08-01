##################################################################################################
# Processes NOAA precipitation data to extract precipitation of wettest quarter for each US county
# Processed data feeds into importation risk model
##################################################################################################

library(tidyverse)
library(r2r)

# Load raw data file
monthly_precipitation <- read.table(file = "raw-data/climdiv-pcpncy-v1.0.0-20230707.txt", header = FALSE, colClasses = c(V1 = "character"))

# Rearranging columns and filtering to data for 2016 and 2017
monthly_precipitation %>% 
  transform(FIPS = substr(V1, 1, 5), Year = substr(V1, 8, 11)) %>% 
  select(-V1) %>% 
  select(FIPS,Year,everything()) %>% 
  filter(Year==2016 | Year==2017) -> monthly_precipitation

# Rename column headers
colnames(monthly_precipitation) <- c('FIPS','Year','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

# State codes used in NOAA dataset are different from ANSI state codes
# Adjust FIPS codes to match US Census Bureau (ANSI standard)
NOAA_to_ANSI <- hashmap()
NOAA_to_ANSI[c("02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","50")] <-
  c("04","05","06","08","09","10","12","13","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56","02")

fips_col_len <- length(monthly_precipitation$FIPS)
for (i in 1:fips_col_len) {
  NOAA_state_code <- substr(monthly_precipitation$FIPS[i],1,2)
  if (NOAA_state_code == "01") {
    next
  }
  substr(monthly_precipitation$FIPS[i],1,2) <- NOAA_to_ANSI[[NOAA_state_code]]
}

# Add Lexington City, Virginia (FIPS 51678) values based on Rockbridge county (51163) values
rockbridge_precip <- monthly_precipitation[monthly_precipitation$FIPS == "51163",]
lexington_precip <- rockbridge_precip %>% 
  mutate(FIPS = str_replace(FIPS,"51163","51678"))
monthly_precipitation <- rbind(monthly_precipitation,lexington_precip)

# Sum precipitation data of each quarter for each year
Q1 <- rowSums(monthly_precipitation[ , c("Jan","Feb","Mar")])
Q2 <- rowSums(monthly_precipitation[ , c("Apr","May","Jun")])
Q3 <- rowSums(monthly_precipitation[ , c("Jul","Aug","Sep")])
Q4 <- rowSums(monthly_precipitation[ , c("Oct","Nov","Dec")])

# Get wettest quarter and its precipitation in inches
quarters <- data.frame(Q1,Q2,Q3,Q4)
max_precipitation <- pmax(Q1,Q2,Q3,Q4)
wettest_quarter <- colnames(quarters)[max.col(quarters)]
Year = monthly_precipitation$Year
FIPS = monthly_precipitation$FIPS
wettest_quarter_data <- data.frame(FIPS,Year,wettest_quarter,max_precipitation)

# Writing data to csv file
write.csv(wettest_quarter_data, "processed-data/county-wettest-quarter.csv", row.names=FALSE)
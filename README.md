# malaria-climate-data
Process historic climate data from NOAA database

## Running the code
* Run `get-average-temp.R` to collect historic monthly average temperature data for each county for years 1895 - 2023.
* Run `get-warmest-month.R` to calculate the maximum temperature of the warmest month for each county for 2016 and 2017.
* Run `get-precipitation.R` to calculate the total amount of precipitation (inches) of the wettest quarter for each county for 2016 and 2017.

## Getting the raw data
The following data files can be found in the `raw-data` folder:
* The file `climdiv-tmpccy-v1.0.0-20230707.txt` contains the raw monthly average temperature data
* The file `climdiv-tmaxcy-v1.0.0-20230707.txt` contains the raw monthly maximum temperature data
* The file `climdiv-pcpncy-v1.0.0-20230707.txt` contains the raw monthly precipitation data

These data files were sourced from the [National Oceanic and Atmospheric Administration](https://www.ncei.noaa.gov/pub/data/cirs/climdiv/). The prior link leads to a directory of datasets as well as a readme file: `county-readme.txt`


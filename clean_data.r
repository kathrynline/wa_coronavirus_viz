# Download google sheet of coronavirus data, and save 
# to be used with R-Shiny tool. 
# Emily Linebarger, last updated March 22, 2020

# Load packages 
library(data.table) 
library(lubridate)

# Read in most recent data (saved in repository) 
repo_dir = "C:/Users/eklin/OneDrive/Documents/GitHub/wa_coronavirus_viz/"
dt = fread(paste0(repo_dir, "COVID-19.csv"))

#---------------------------
# Munge data 
#---------------------------
# Only keep from names row down 
names(dt) = as.character(dt[3])
dt = dt[4:nrow(dt)]

# Format names nicely 
names_clean = tolower(names(dt))
names_clean = gsub(" ", "_", names_clean)
names_clean = gsub("\\(|\\)", "", names_clean)
names(dt) = names_clean

# Remove percentage signs, and convert everything else to numeric
dt[, percent_test_increase:=gsub("%", "", percent_test_increase)]
dt[, percent_case_increase:=gsub("%", "", percent_case_increase)]

num_vars = names(dt)[!names(dt)=='date']
for (var in num_vars){
  dt[, (var):=as.numeric(get(var))]
}

# Fix date format 
dt[, date:=as.Date(date, fmt="%Y-%m-%d")]

#------------------------
# Save data 
#------------------------
write.csv(dt, paste0(repo_dir, "clean_data.csv"), row.names=F)

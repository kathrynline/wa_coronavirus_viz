# Script to deploy R shiny app 
# Run line-by-line! 

library(data.table) 
library(rsconnect) 
library(shiny) 
library(readxl)

filePath = "C:/Users/elineb/Documents/wa_coronavirus_viz/wa_coronavirus"

rsconnect::deployApp(paste0(filePath))

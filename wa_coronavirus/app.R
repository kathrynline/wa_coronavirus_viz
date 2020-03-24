#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(data.table) 

# Format your data 
max_date = "2020-03-23" # Set to the last updated date 

dt = fread("clean_data.csv")
dt = dt[date<=max_date] # Remove data after last day of reporting 

# Separate out into the two data tables you want to show - totals to date, and change day-to-day
totals_to_date = dt[, .(date, total_cases, total_deaths, total_tests_to_date)]
totals_to_date_disp = copy(totals_to_date)
names(totals_to_date_disp) <- c('Date', 'Total Cases', 'Total Deaths', 'Total Tests')
daily_change = dt[, .(date, new_tests, new_cases, new_deaths)]
daily_change_disp = copy(daily_change)
names(daily_change_disp) <- c('Date', 'New Tests', 'New Cases', 'New Deaths')

disp = merge(totals_to_date_disp, daily_change_disp, by='Date', all=T)

# Format data for graph
totals_to_date = melt(totals_to_date, id.vars=c('date'))
daily_change = melt(daily_change, id.vars=c('date'))

# Set up labels 
totals_to_date[variable=="total_cases", label:="Total Cases"]
totals_to_date[variable=="total_deaths", label:="Total Deaths"]
totals_to_date[variable=="total_tests_to_date", label:="Total Tests"]

daily_change[variable=="new_tests", label:="New tests"]
daily_change[variable=="new_cases", label:="New cases"]
daily_change[variable=="new_deaths", label:="New deaths"]

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("COVID-19 in Washington State"),
  
  sidebarLayout(
    # Sidebar with a slider input for number of bins 
    sidebarPanel(
      radioButtons('scale', 'Select graph view',
                   c('Linear scale'='norm', 'Log Scale'='log')), 
      radioButtons('type', 'Select which data to display',
                   c('Daily change'='daily_change', 'Total to date'='totals')),
      p(em("Data taken from the Washington Department of Health Website:")),
      p(em("\"https://www.doh.wa.gov/Emergencies/Coronavirus\""))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot1", hover = "plot_click"), 
      dataTableOutput('summaryTable')
    )
  )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
    output$plot1 <- renderPlot({
      if (input$type=="daily_change"){
        p =  ggplot(daily_change, aes(x=date, y=value, color=label, group=label))
      } else {
        p =  ggplot(totals_to_date, aes(x=date, y=value, color=label, group=label))
      }
      p =  p + 
        geom_line(size=1) + geom_point(size=3) +  
        theme_bw(base_size=16) + 
        theme(axis.text.x=element_text(angle=30, vjust=0.5)) + 
        labs(x="Date", y="", color="")
      if (input$scale =='log'){
        p = p + scale_y_log10() 
      }
      p 
    })
    
    output$summaryTable <- renderDataTable(disp)
}

# Run the application 
shinyApp(ui = ui, server = server)

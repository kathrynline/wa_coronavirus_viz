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
max_date = "2020-03-22" # Set to the last updated date 

dt = fread("clean_data.csv")
dt = dt[, .(date, total_cases, total_deaths, total_tests_to_date)]
dt_long = copy(dt)
dt = dt[date<=Sys.Date()] # Remove data after today 
dt = melt(dt, id.vars=c('date'))

# Set up labels 
dt[variable=="total_cases", label:="Total Cases"]
dt[variable=="total_deaths", label:="Total Deaths"]
dt[variable=="total_tests_to_date", label:="Total Tests to Date"]


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("COVID-19 in Washington State"),
  
  sidebarLayout(
    # Sidebar with a slider input for number of bins 
    sidebarPanel(
      radioButtons('scale', 'Select graph view',
                   c('Linear scale'='norm', 'Log Scale'='log')), 
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
    p =  ggplot(dt, aes(x=date, y=value, color=label, group=label)) + 
      geom_line(size=1) + geom_point(size=3) +  
      theme_bw(base_size=16) + 
      theme(axis.text.x=element_text(angle=30, vjust=0.5)) + 
      labs(x="Date", y="", color="")
    if (input$scale =='log'){
      p = p + scale_y_log10() 
    }
    p 
  })
  
  output$summaryTable <- renderDataTable(dt_long)
  
}

# Run the application 
shinyApp(ui = ui, server = server)

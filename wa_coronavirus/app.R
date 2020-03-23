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

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("COVID-19 in Washington State"),
    
    # Sidebar with a slider input for number of bins 
    sidebarPanel(
        radioButtons('scale', 'Select graph view',
                c('Linear scale'='norm', 'Log Scale'='log'),)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        plotOutput("plot1", click = "plot_click"),
        verbatimTextOutput("info")
    ),
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    max_date = Sys.Date() # Set to today's date 
    labels = data.table(lab = c('total_cases', 'total_deaths', 'total_tests_to_date'), 
                        date=rep(max_date, 3), 
                        value=as.numeric(c(dt[date==max_date, .(total_cases, total_deaths, total_tests_to_date)])))
    
    output$plot1 <- renderPlot({
       p =  ggplot(dt, aes(x=date)) + 
            geom_point(aes(y=total_cases), color="red") + 
            geom_line(aes(y=total_cases), color="red") + 
            geom_point(aes(y=total_deaths), color="blue") + 
            geom_line(aes(y=total_deaths), color="blue") + 
            geom_point(aes(y=total_tests_to_date), color="green") + 
            geom_line(aes(y=total_tests_to_date), color="green") + 
            geom_text(data=labels, aes(x=date, y=value, label=lab)) + 
            theme_bw(base_size=16) + 
            labs(x="Date", y="")
            if (input$scale =='log'){
                p = p + scale_y_log10() 
            }
       p 
    })
    
    output$info <- renderText({
        paste0("Date=", input$plot_click$x, "\nTotal Cases=", input$plot_click$y)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

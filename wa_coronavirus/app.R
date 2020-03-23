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
    # sidebarPanel(
    # selectInput('Select graph view', 'scale',
    #             c('Normal scale'='norm', 'Log Scale'='log'),
    #             plotOutput("plot1", click = "plot_click"))
    # ), 
    
    # Show a plot of the generated distribution
    mainPanel(
        plotOutput("plot1", click = "plot_click"),
        verbatimTextOutput("info")
    ),
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$plot1 <- renderPlot({
        ggplot(dt, aes(x=date)) + 
            geom_point(aes(y=total_cases), color="red") + 
            theme_bw(base_size=16) + 
            scale_y_log10() + 
            labs(x="Date", y="")
    })
    
    output$info <- renderText({
        paste0("Date=", input$plot_click$x, "\nTotal Cases=", input$plot_click$y)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

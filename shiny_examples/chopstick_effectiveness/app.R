#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

#read in dataset
chopsticks <- read_csv("chopstick-effectiveness.csv")

#changes '.' to '_' in col names
names(chopsticks) <- str_replace_all(string = names(chopsticks), pattern = "\\.", replacement = "_")

#factor chopstick length
chopsticks$Chopstick_Length <- factor(chopsticks$Chopstick_Length)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Analysis of Chopstick Effectiveness"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         radioButtons(inputId = "chopstick_length",
                    label = "Select Chopstick Length",
                    choices = levels(chopsticks$Chopstick_Length)),
         numericInput(inputId = "bin_number", label = "Number of Bins",
                      value = 30, min = 1, 
                      max = 50, step = 1),
         textInput(inputId = "plot_title", label = "Plot Title", 
                   placeholder = "Enter text to be used as plot title")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot"),
         textOutput("plot_info")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  chopsticks_subset <- reactive({chopsticks %>%
    filter(Chopstick_Length == input$chopstick_length)
    })
  
   output$distPlot <- renderPlot({
     req(input$bin_number)
      ggplot(chopsticks_subset(), aes(x = Food_Pinching_Effeciency)) +
       geom_histogram(bins = input$bin_number) +
        labs(title = isolate({tools::toTitleCase(input$plot_title)}))
      })
   
   output$plot_info <- renderText({
     paste("Notice that the plot title:", input$plot_title, 
         "doesn't update until one of the other inputs is updated. That's because it is 'isolated'.")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)


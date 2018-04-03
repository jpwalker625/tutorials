#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  observeEvent(input$submit, {
    
    df <- data.frame(strain = str_split(input$strains, boundary("word")),
                     name = paste(input$first_name, input$last_name), 
                     date = input$date)
    
    output$ynums <- renderDataTable({df})
  
})
})

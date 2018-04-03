#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(textInput("first_name",label = "first"),
                 textInput("last_name", label = "Last"),
                 textAreaInput("strains", "strains"),
                 dateInput("date", label = "Date", value = Sys.Date()),
                 actionButton("submit", "Submit")
    ),
      
  mainPanel(
    dataTableOutput("ynums")
  )
  )
))

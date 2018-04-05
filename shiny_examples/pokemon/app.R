library(shiny)
library(tidyverse)
library(DT)


pokemon <- read_csv("pokemon.csv")

names(pokemon) <- tolower(names(pokemon)) 
names(pokemon) <- gsub(pattern = "\\. ", replacement = "_", x = names(pokemon))
names(pokemon) <- gsub(pattern = " ", "", names(pokemon))

#select only columns with numeric data
choices <- pokemon %>%
  select(4:10) %>% names()

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Pokemon Analysis"),
   
   # Sidebar with a checkbox input
   sidebarLayout(
     sidebarPanel(
       #y-axis selector
       selectInput(inputId = "y", label = "y-axis",
                   choices = choices, selectize = T, selected = "attack"),
       #x-axis selector
       selectInput(inputId = "x", label = "x-axis", 
                   choices = choices, selectize = T, "total"),
       #check box for faceting
       checkboxInput(inputId = 'faceted', label = "Facet by Legendary Status?", value = F),
       # enter value for sample size
       numericInput(inputId = "n", label = "Sample Size", value = 30, min = 1, max = 800),
       # Enter text for plot title
       textInput(inputId = "plot_title", 
                 label = "Plot title", 
                 placeholder = "Enter text for plot title")
     ),
     # Output:
     mainPanel(
       # Show scatterplot with brushing capability
       plotOutput(outputId = "scatterplot", brush = "plot_brush"),
       # Show data table
       dataTableOutput(outputId = "poke_stats"),
       br()
     )
   )

)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  #convert plot title to TitleCase
  pretty_plot_title <- reactive({
    tools::toTitleCase(paste(input$plot_title, "is a reactive plot title. This plot contains:", input$n, "data points", sep = " "))
  })
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    req(input$n) # gets rid of error if the numeric input is cleared
    if(input$faceted){
      pokemon %>% sample_n(input$n) %>%
    ggplot(aes_string(x = input$x, y = input$y, color = "type2")) +
      geom_point() +
        facet_wrap(~legendary) +
        labs(title = pretty_plot_title())
    }
    else if(input$faceted == F){
      pokemon %>% sample_n(input$n) %>%
      ggplot(aes_string(x = input$x, y = input$y, color = "legendary")) +
        geom_point() +
        labs(title = pretty_plot_title())
    }
  })
  
  # Create data table
  output$poke_stats <- DT::renderDataTable({
    brushedPoints(pokemon, input$plot_brush)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)


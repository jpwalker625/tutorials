library(shiny)
library(tidyverse)
library(DT)


pokemon <- read_csv("pokemon.csv")

names(pokemon) <- tolower(names(pokemon)) 
names(pokemon) <- gsub(pattern = "\\. ", replacement = "_", x = names(pokemon))
names(pokemon) <- gsub(pattern = " ", "", names(pokemon))

pokemon <- pokemon %>%
  mutate(legendary = factor(if_else(legendary == TRUE, "Legendary", "Normal")))

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
       wellPanel(
       #y-axis selector
       selectInput(inputId = "y", label = "y-axis",
                   choices = choices, selectize = T, selected = "attack"),
       #x-axis selector
       selectInput(inputId = "x", label = "x-axis", 
                   choices = choices, selectize = T, "total")
       ),
       wellPanel(
       # enter value for sample size
       numericInput(inputId = "n", label = "Sample Size", value = 30, min = 1, max = 800),
       # Enter text for plot title
       textInput(inputId = "plot_title", 
                 label = "Plot title",
                 placeholder = "Enter text for plot title")
       ),
       wellPanel(
         #check box for faceting
         checkboxInput(inputId = 'faceted', label = "Facet by Legendary Status?", value = F),
         #checkbox input for complete dataset tab
         checkboxInput(inputId = "show_data", label = "Show Complete Pokemon Data Set Tab?", value = FALSE))
     ),
     # Output:
     mainPanel(
       tabsetPanel(id = 'tabspanel', type = "pills",
                   tabPanel(title = "Plot",
                            # Show scatterplot with brushing capability
                            plotOutput(outputId = "scatterplot", brush = brushOpts(id = "plot_brush",resetOnNew = T)),
                            br(),
                            #
                            h4(textOutput(outputId = "brush_text")),
                            hr(),
                            # Show data table
                            dataTableOutput(outputId = "poke_stats"),
                            br()
                            ),
                   tabPanel(title = "dataset",
                            dataTableOutput(outputId = "pokemon_dataset"))
       )
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  #convert plot title to TitleCase
  pretty_plot_title <- reactive({
    tools::toTitleCase(paste(input$plot_title, "is a reactive plot title. This plot contains:", input$n, "data points", sep = " "))
  })
  
  pokemon_subset <- reactive({
    pokemon %>% sample_n(input$n)
  })
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    req(input$n) # gets rid of error if the numeric input is cleared
    if(input$faceted){
    ggplot(pokemon_subset(), aes_string(x = input$x, y = input$y, color = "type2")) +
      geom_point() +
        facet_wrap(~legendary) +
        labs(title =pretty_plot_title())
    }
    else if(input$faceted == F){
      ggplot(pokemon_subset(), aes_string(x = input$x, y = input$y, color = "legendary")) +
        geom_point() +
        labs(title = pretty_plot_title())
    }
  })
  
  # Create data table
  output$poke_stats <- renderDataTable({
    req(input$plot_brush)
    brushedPoints(pokemon_subset(), input$plot_brush)
  })
  
  #create conditional brush text instructions
  output$brush_text <- renderText({
    if(length(input$plot_brush) == 0 ){
    paste("This is a dynamic plot. Click and drag over the points you want to see more information about.")
    }
      })
  
  #conditional observer for the pokemon dataset tab
  observeEvent(input$show_data, {
    if(input$show_data){
      showTab(inputId = "tabspanel", target = "dataset", select = T)
    } else {
      hideTab(inputId = "tabspanel", target = "dataset")
    }
  })
  
  #render the pokemon data table
  output$pokemon_dataset <- renderDataTable({
    datatable(data = pokemon, caption = "Pokemon Dataset")
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)


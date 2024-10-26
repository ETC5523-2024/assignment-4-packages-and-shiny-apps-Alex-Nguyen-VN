library(shiny)
library(shinyjs)  # Load shinyjs for JavaScript capabilities
library(dplyr)
library(ggplot2)
library(ausrooftop)

ui <- fluidPage(
  shinyjs::useShinyjs(),  # Initialize shinyjs
  titlePanel("Explore My Dataset"),
  sidebarLayout(
    sidebarPanel(
      # Add selectors/input fields here
      selectInput("region", "Select Region:", choices = unique(actual_demand_june$REGIONID)),
      actionButton("lucky_button", "I'm Feeling Lucky")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    # Generate a plot based on user input
    data_1 <- subset(actual_demand_june, REGIONID == input$region)
    data_2 <- subset(actual_RV_gen, REGIONID == input$region)
    data_3 <- data_1 |>
      group_by(REGIONID, TIME) |>
      summarise(
        mean_demand = mean(OPERATIONAL_DEMAND, na.rm = TRUE),
        sd_demand = sd(OPERATIONAL_DEMAND, na.rm = TRUE)
      )
    data_4 <- data_2 |>
      group_by(REGIONID, TIME) |>
      summarise(
        mean_gen = mean(POWER, na.rm = TRUE),
        sd_gen = sd(POWER, na.rm = TRUE)
      )
    data_4 |>
      ggplot(aes(x = TIME, y = mean_gen)) +
      geom_line() +
      scale_x_time(labels = scales::time_format("%H:%M"), breaks = scales::breaks_width("8 hours")) +
      geom_line(data = data_3, aes(x = TIME, y = mean_demand), color = "red") +
      geom_vline(xintercept = as.numeric(hms("07:00:00")), linetype = "dashed") +
      geom_vline(xintercept = as.numeric(hms("18:00:00")), linetype = "dashed") +
      labs(title = paste("Mean Power Generation and Demand for", input$region),
           x = "Time of Day",
           y = "Power (MW)")
    })
  # Observe the "I'm Feeling Lucky" button click
  observeEvent(input$lucky_button, {
    # Trigger JavaScript to open a new window with the Rickroll video
    shinyjs::runjs('window.open("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "_blank");')
  })
}


shinyApp(ui = ui, server = server)

library(shiny)
library(shinyjs)        # Load shinyjs for JavaScript capabilities
library(shinydashboard)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)
library(ausrooftop)

# Define a custom theme
my_theme <- bs_theme(
  version = 4,
  bootswatch = "darkly",
  primary = "#3498db",
  secondary = "#2ecc71"
)

# Define the UI
ui <- dashboardPage(
  dashboardHeader(title = "Renewable Generation Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    shinyjs::useShinyjs(),  # Initialize shinyjs
    bs_theme_dependencies(my_theme),
    tabItems(
      # Dashboard tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                # Summary Boxes
                valueBoxOutput("total_demand", width = 3),
                valueBoxOutput("average_demand", width = 3),
                valueBoxOutput("total_gen", width = 3),
                valueBoxOutput("average_gen", width = 3)
              ),
              fluidRow(
                # Filter options and plot
                box(
                  title = "Filters", width = 4, solidHeader = TRUE, status = "primary",
                  selectInput("region", "Select Region:", choices = unique(actual_demand_june$REGIONID)),
                  actionButton("lucky_button", "I'm Feeling Lucky")
                ),
                box(
                  title = "Mean Power Generation and Demand Over Time", width = 8, solidHeader = TRUE, status = "primary",
                  plotOutput("plot")
                )
              ),
              fluidRow(
                # Field Description
                box(
                  title = "Field Descriptions", width = 6, status = "info", solidHeader = TRUE,
                  p("REGIONID: Unique identifier for each region."),
                  p("OPERATIONAL_DEMAND: The actual operational demand recorded in megawatts (MW)."),
                  p("POWER: The renewable power generation measured in megawatts (MW)."),
                  p("INTERVAL_DATETIME: Date and time of the data recording interval."),
                  p("DATE: The date of each recorded interval."),
                  p("TIME: The time of each recorded interval.")
                ),
                # Interpretation Guide
                box(
                  title = "How to Interpret the Outputs", width = 6, status = "info", solidHeader = TRUE,
                  p("The summary boxes display the total and average demand and generation values for the selected region."),
                  p("The line plot shows the average demand (in red) and average generation (in green) over time."),
                  p("Dashed vertical lines indicate typical daytime hours (7:00 AM to 6:00 PM), helping to analyze demand and generation patterns."),
                  p("The data table provides a detailed view of the demand and generation values for each interval, which can be sorted or filtered for further analysis.")
                )
              ),
              fluidRow(
                # Data Table
                box(
                  title = "Demand and Generation Data", width = 12, solidHeader = TRUE, status = "primary",
                  dataTableOutput("data_table")
                )
              )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {

  # Summary metrics
  output$total_demand <- renderValueBox({
    regional_demand <- actual_demand_june %>% filter(REGIONID == input$region)
    total_demand <- sum(regional_demand$OPERATIONAL_DEMAND, na.rm = TRUE)
    valueBox(total_demand, "Total Demand (MW)", icon = icon("bolt"), color = "blue")
  })

  output$average_demand <- renderValueBox({
    regional_demand <- actual_demand_june %>% filter(REGIONID == input$region)
    avg_demand <- mean(regional_demand$OPERATIONAL_DEMAND, na.rm = TRUE)
    valueBox(round(avg_demand, 2), "Average Demand (MW)", icon = icon("tachometer-alt"), color = "green")
  })

  output$total_gen <- renderValueBox({
    regional_gen <- actual_RV_gen %>% filter(REGIONID == input$region)
    total_gen <- sum(regional_gen$POWER, na.rm = TRUE)
    valueBox(total_gen, "Total Generation (MW)", icon = icon("sun"), color = "yellow")
  })

  output$average_gen <- renderValueBox({
    regional_gen <- actual_RV_gen %>% filter(REGIONID == input$region)
    avg_gen <- mean(regional_gen$POWER, na.rm = TRUE)
    valueBox(round(avg_gen, 2), "Average Generation (MW)", icon = icon("chart-line"), color = "purple")
  })

  # Plot based on region selection
  output$plot <- renderPlot({
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
      geom_line(color = "#2ecc71") +  # Power generation line
      scale_x_time(labels = scales::time_format("%H:%M"), breaks = scales::breaks_width("8 hours")) +
      geom_line(data = data_3, aes(x = TIME, y = mean_demand), color = "#e74c3c") +  # Demand line
      geom_vline(xintercept = as.numeric(lubridate::hms("07:00:00")), linetype = "dashed", color = "black", linewidth = 1) +
      geom_vline(xintercept = as.numeric(lubridate::hms("18:00:00")), linetype = "dashed", color = "black", linewidth = 1) +
      labs(title = paste("Mean Power Generation and Demand for", input$region),
           x = "Time of Day",
           y = "Power (MW)")
  })

  # Data Table for demand and generation
  output$data_table <- renderDataTable({
    merged_data <- merge(actual_demand_june, actual_RV_gen, by = c("REGIONID", "INTERVAL_DATETIME", "DATE", "TIME"), all = TRUE)
    datatable(merged_data)
  })

  # "I'm Feeling Lucky" button functionality
  observeEvent(input$lucky_button, {
    shinyjs::runjs('window.open("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "_blank");')
  })
}

# Run the app
shinyApp(ui = ui, server = server)

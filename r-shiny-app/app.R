library(shiny)
library(ggplot2)
library(shinythemes)
library(dplyr)
library(plotly)

data <- read.csv('salary-pred.csv')
data <- data[order(data$tm),]

ui <- fluidPage(theme = shinytheme('paper'),
                
                titlePanel("Using machine learning to find the best and worst value contracts"),
                
  
                tabsetPanel(
                  tabPanel("Introduction", fluid = TRUE,
                           
                           mainPanel(
                             h1('Methods'),
                             p("To find the best and worst value contracts, we created 4 machine learning models. We trained the models on annual data from every season
                                since the salary cap was introduced in the 1984-1985 season. The models use a player's annual stats to predict what percentage of the cap
                                they should earn. We use percentage of cap instead of salary because inflation and the increase in the salary cap make raw salary numbers
                                unstable. By averaging these predicted percentage of the cap, we have a contract value for each player. We can compare this to their actual
                                percentage of the cap. A higher difference means the player is a good value, as their predicted percentage is higher than their real.",
                               style = "font-size:16px"),
                             br(),
                             p("This dashboard helps visualize the difference between player contract value and a player's actual contract. You can look at each team's
                                contracts to see who is under or over paying players. You can also search for specific players to see their value.", style = "font-size:16px"),
                             h1("Links"),
                             a(href="https://dribbleanalytics.blog/2020/01/contract-value",
                               div("Click here to see the original blog post which includes a more detailed discussion of methods and results.", style = 'font-size:16px')),
                             br(),
                             a(href="https://github.com/dribbleanalytics/contract-value/",
                               div("Click here to see the GitHub repository for the project which contains all code, data, and results.", style = 'font-size:16px'))
                             
                             )
                           ),
                  tabPanel("Team-by-team contracts", fluid = TRUE,
                           sidebarLayout(
                             sidebarPanel(p("To examine the contracts on any team, select a team from the dropdown menu below. The graphs will automatically update.
                                             The trendline shown is y = x, or when predicted value = actual value. A player on this line is valued correctly. Players above
                                             are overpaid, while players below are underpaid.",
                                            style = 'font-size:16px'),
                                          br(),
                                          
                                          selectInput(inputId = "team",
                                                      label = "Select team:",
                                                      choices = unique(data$tm))
                                          
                             ),
                             mainPanel(plotlyOutput(outputId = "team_scat")
                                       )
                             )
                           ),
                  tabPanel("Team-wide salary", fluid = TRUE,
                           sidebarLayout(
                             sidebarPanel(p("This shows the total contract value for each team. The trendline shown is y = x, or when predicted value = actual value. 
                                             If a team is above the trendline, they are overpaying players. If a team
                                             is below the trendline, they are getting good value. Search a team and their point on the plot will automatically
                                             change color.", style = 'font-size:16px'),
                                          br(),
                                          
                                          selectInput(inputId = "team_col",
                                                      label = "Select team:",
                                                      choices = unique(data$tm))
                                          ),
                           
                           mainPanel(plotlyOutput(outputId = "league_team_scat")
                                     )
                           )),
                  tabPanel("League-wide salary", fluid = TRUE,
                           sidebarLayout(
                             sidebarPanel(p("This shows the total contract value for every player in the league. Select a player from the dropdown menu below.
                                             His point in the scatter plot will change color to highlight that player.", style = 'font-size:16px'),
                                          br(),
                                          selectInput(inputId = "player",
                                                      label = "Select player:",
                                                      choices = unique(data$player)),
                                          
                             ),
                             
                             mainPanel(plotlyOutput(outputId = "league_scat")
                             )
                             ))
                  )
                )



server <- function(input, output) {
  
  
  output$team_scat <- renderPlotly({
    
    team_data <- data[which(data$tm == input$team),]
    
    p <- ggplot(team_data, aes(x = avg, y = percent_of_cap)) + 
      geom_point(aes(text = player)) +
      xlab('Predicted % of cap') +
      ylab('Actual % of cap') +
      geom_abline(slope = 1, intercept = 0) +
      xlim(range(0, .4)) +
      ylim(range(0, .4)) +
      theme_light()
    
    ggplotly(p, tooltip="text") %>%
      layout(autosize=TRUE)
    
  })
  
  output$league_team_scat <- renderPlotly({
    
    sum_team <- data.frame(data %>% 
                  group_by(tm) %>%                            
                  summarise(avg = sum(avg), percent_of_cap = sum(percent_of_cap)))
    
    sum_team$color <- ifelse(sum_team$tm == input$team_col, "green", "black")
    
    p <- ggplot(sum_team, aes(x = avg, y = percent_of_cap)) + 
      geom_point(aes(color = color, text = tm)) +
      xlab('Predicted % of cap') +
      ylab('Actual % of cap') +
      geom_abline(slope = 1, intercept = 0) +
      xlim(range(0.7, 1.6)) +
      ylim(range(0.7, 1.6)) +
      theme_light()
    
    hide_legend(ggplotly(p, tooltip = "text") %>%
      layout(autosize=TRUE))
    
  })
  
  output$league_scat <- renderPlotly({
    
    data$color <- ifelse(data$player == input$player, "green", "black")
    
    p <- ggplot(data, aes(x = avg, y = percent_of_cap)) +
      geom_point(aes(color = color, text = player)) +
      xlab("Predicted % of cap") +
      ylab("Actual % of cap") +
      geom_abline(sline = 1, intercept = 0) +
      xlim(range(0, .4)) +
      ylim(range(0, .4)) +
      theme(legend.position = "none") +
      theme_light()
    
    hide_legend(ggplotly(p, tooltip = "text") %>%
      layout(autosize = TRUE))
    
  })
  
}

shinyApp(ui = ui, server = server)

library(dplyr)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(ggplot2)
library(gdata)
library(scales)
library(stringr)
library(gridExtra)
library(maps)
library(httr)
library(jsonlite)
library(plotly)

setwd("~/Projects/Police Shootings")

police_killings <- read.csv(url("https://github.com/washingtonpost/data-police-shootings/releases/download/v0.1/fatal-police-shootings-data.csv"))


police_killings$date <- as.character(police_killings$date)
police_killings$date <- str_sub(police_killings$date, 1, 4)

max_year = max(as.numeric(police_killings$date))

shinyUI(dashboardPage(skin="black",
                      dashboardHeader(title = "Police Killings by State", titleWidth=300),
                      dashboardSidebar(
                        sidebarMenu(id="tabs",
                                    menuItem("Police Killings", tabName = "police_killings", icon = icon("star-o")),
                                    menuItem("About", tabName = "about", icon = icon("question-circle")),
                                    
                                    
                                    conditionalPanel(condition = "input.tabs == 'police_killings'",                     
                      

                      
                      selectInput("demographic_variable", label = h5("Choose a statistic"),
                                  list("Median Income" = "Median.Income",
                                       "Percent African-American" = "perc_black",
                                       "Percent Hispanic" = "perc_hisp",
                                       "Percent Minority" = "perc_minority",
                                       "Poverty Rate" = "PovertyRate"
                                       ),selected = "PovertyRate"),
                      
                      sliderInput("year", label = "Year:",
                                  min = 2015, max = max_year, value = 2015, ticks = F, sep=""),

                      
                      
                                    ))),
        
        
        dashboardBody(
          tags$head(
            tags$style(type="text/css", "select { max-width: 360px; }"),
            tags$style(type="text/css", ".span4 { max-width: 360px; }"),
            tags$style(type="text/css",  ".well { max-width: 360px; }")
            
        ),
        
        conditionalPanel(condition = "input.tabs == 'about'",
                         tabItem(tabName = "about",
                                 h2("About this App"),
                                 HTML('<br/>'),
                                 fluidRow(
                                         box(title = "Author: Max Rodrigues", background = "black", width=7, collapsible = F,
                                             
                                             helpText(p(strong("Exploration of police killings data from the Washington Post. Data is pulled directly from the Washington Post Github and updated daily."))),
                                             
                                             helpText(p("Please contact me at my email mrod1791@gmail.com or visit my",
                                                        a(href ="https://mrodrigues17.github.io./", "personal page", target = "_blank"),
                                                        "for more information, to suggest improvements or report errors.")))))),
        
        
        
        
        conditionalPanel(condition = "input.tabs == 'police_killings'",
                         

                         
                         tabItem(tabName = "police_killings",
                                 box(plotOutput("plot"),
                                     
                                      width=11,height=7, collapsible = FALSE)))
        
        
        ),
        
        )
)

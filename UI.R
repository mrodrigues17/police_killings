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


shinyUI(dashboardPage(skin="black",
                      dashboardHeader(title = "Police Killings by State", titleWidth=300),
                      dashboardSidebar(
                        sidebarMenu(id="tabs",
                                    menuItem("Police Killings", tabName = "police_killings", icon = icon("star-o")),
                                    menuItem("About", tabName = "about", icon = icon("question-circle")),
                                    
                                    
                                    conditionalPanel(condition = "input.tabs == 'police_killings'",                     
                      
                      sliderInput("year", label = "Year:",
                                  min = 2015, max = 2021, value = 2015, ticks = F)
                      
                                    ))),
        
        
        dashboardBody(
          tags$head(
            tags$style(type="text/css", "select { max-width: 360px; }"),
            tags$style(type="text/css", ".span4 { max-width: 360px; }"),
            tags$style(type="text/css",  ".well { max-width: 360px; }")
            
        ),
        conditionalPanel(condition = "input.tabs == 'police_killings'",
                         
                         
                         
                         tabItem(tabName = "police_killings",
                                 box(plotOutput("plot"), width=11,height=7, collapsible = TRUE)))
        
        
        ),
        
        
        
        
        
        ))

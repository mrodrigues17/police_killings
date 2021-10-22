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
                      
                      sliderInput("year", label = "Year:",
                                  min = 2015, max = max_year, value = 2015, ticks = F, sep="")

                      
                      
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

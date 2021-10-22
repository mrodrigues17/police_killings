library(ggplot2)
library(gdata)
library(scales)
library(stringr)
library(gridExtra)
library(maps)
options(scipen=999)

shinyServer(function(input, output) {
  #testing
  setwd("~/Projects/Police Shootings")
  
  police_killings <- read.csv(url("https://github.com/washingtonpost/data-police-shootings/releases/download/v0.1/fatal-police-shootings-data.csv"))
  percentage_below_poverty <- read.csv("PercentagePeopleBelowPovertyLevel.csv")
  poverty_rates <- read.csv("poverty_rate.csv")
  population_data <- read.csv("populationData.csv")
  median_household_income <- read.csv("MedianHouseholdIncome2015.csv")
  share_race_by_city <- read.csv("ShareRaceByCity.csv")
  
  
  
  
  
  police_killings$date <- as.character(police_killings$date)
  police_killings$date <- str_sub(police_killings$date, 1, 4)
  police_killings$date <- as.factor(police_killings$date)
  
  
  police_killings_grouped <- police_killings %>%
    group_by(date, state) %>%
    summarise(killings = n())
  
  
  
  police_killings_grouped <- left_join(police_killings_grouped, population_data,
                                       by = c("state" = "Abbreviations"))
  
  
  
  median_household_income$Median.Income <- as.character(median_household_income$Median.Income)
  median_household_income$Median.Income <- as.numeric(median_household_income$Median.Income)
  
  median_household_income_state <- median_household_income %>%
    group_by(Geographic.Area) %>%
    summarise(Median.Income = median(Median.Income, na.rm = T))
  
  police_killings_grouped <- left_join(police_killings_grouped, median_household_income_state,
                                       by = c("state" = "Geographic.Area"))
  
  
  share_race_by_city$share_black <- as.character(share_race_by_city$share_black)
  share_race_by_city$share_hispanic <- as.character(share_race_by_city$share_hispanic)
  
  share_race_by_city$share_black <- as.numeric(share_race_by_city$share_black)
  share_race_by_city$share_hispanic <- as.numeric(share_race_by_city$share_hispanic)
  
  
  share_race_by_state <- share_race_by_city %>%
    group_by(Geographic.area) %>%
    summarise(perc_black = mean(share_black, na.rm = T), perc_hisp = mean(share_hispanic, na.rm = T))
  
  police_killings_grouped <- left_join(police_killings_grouped, share_race_by_state,
                                       by = c("state" = "Geographic.area"))
  
  police_killings_grouped$perc_minority <- police_killings_grouped$perc_black + police_killings_grouped$perc_hisp
  
  police_killings_grouped$perc_minority <- police_killings_grouped$perc_minority/100
  
  percentage_below_poverty$poverty_rate <- as.character(percentage_below_poverty$poverty_rate)
  
  percentage_below_poverty$poverty_rate <- as.double(percentage_below_poverty$poverty_rate)
  
  percentage_below_poverty <- percentage_below_poverty %>%
    group_by(Geographic.Area) %>%
    summarise(poverty_rate = mean(poverty_rate, na.rm = T))
  
  police_killings_grouped <- left_join(police_killings_grouped, percentage_below_poverty,
                                       by = c("state" = "Geographic.Area"))
  
  
  
  
  
  
  police_killings_grouped$per_capita_killings <- police_killings_grouped$killings
  
  for (i in levels(police_killings_grouped$date)){
    police_killings_grouped$per_capita_killings[police_killings_grouped$date == i] <- (police_killings_grouped$killings[police_killings_grouped$date == i]/police_killings_grouped$POPESTIMATE2017[police_killings_grouped$date == i]) *100000
    
  }
  
  
  Pacific <- c("CA", "HI", "AK", "WA", "OR", "NV", "AZ")
  Frontier <- c("ID", "MT", "UT", "OK", "TX", "KS", "NM", "CO","WY")
  Midwest <- c("ND", "SD", "NE", "IA", "IL", "IN", "WI", "MI", "OH", "MN", "MO")
  South <- c("KY", "TN", "WV", "FL", "GA", "MS", "AL", "LA", "AR", "VA", "NC", "SC")
  NorthEast <- c("NY", "DC", "CT", "DE", "ME", "MD", "MA", "NH", "NJ", "PA", "RI", "VT")
  
  
  police_killings_grouped$Region[police_killings_grouped$state %in% Pacific] <- 'Pacific'
  police_killings_grouped$Region[police_killings_grouped$state %in% Frontier] <- 'Frontier'
  police_killings_grouped$Region[police_killings_grouped$state %in% Midwest] <- 'Midwest'
  police_killings_grouped$Region[police_killings_grouped$state %in% South] <- 'South'
  police_killings_grouped$Region[police_killings_grouped$state %in% NorthEast] <- 'North East'
  police_killings_grouped$Region <- as.factor(police_killings_grouped$Region)
  
  all_states <- map_data("state")
  
  MidwestNames <- tolower(state.name[match(Midwest,state.abb)])
  SouthNames <- tolower(state.name[match(South,state.abb)])
  FrontierNames <- tolower(state.name[match(Frontier,state.abb)])
  PacificNames <- tolower(state.name[match(Pacific,state.abb)])
  NorthEastNames <- tolower(state.name[match(NorthEast,state.abb)])
  
  #levels(police_killings_grouped$date)[1] <- "2015"
  #levels(police_killings_grouped$date)[2] <- "2016"
  #levels(police_killings_grouped$date)[3] <- "2017"
  #levels(police_killings_grouped$date)[4] <- "2018"
  
  poverty_rates$State <- state.abb[match(poverty_rates$ï..State,state.name)]
  
  
  
  
  police_killings_grouped <- left_join(police_killings_grouped, poverty_rates, 
                                       by = c("state" = "State"))
  
  police_killings_grouped$PovertyRate[police_killings_grouped$state == "DC"] <- 19.0
  
  police_killings_grouped$date <- as.character(police_killings_grouped$date)
  
  #police_killings_grouped$date <- as.numeric(police_killings_grouped$date)
  

  
  
  
  output$plot <- renderPlot({
  
  xleft = 1.75
  xright = 0.57
  ybottom = -.07
  ytop = .2
  
  
  plot1 <- ggplot(data = police_killings_grouped[police_killings_grouped$date == input$year,], aes(x = PovertyRate, y = per_capita_killings, size = POPESTIMATE2017, fill = Region)) +
    geom_point(alpha = .9, pch=21, color = "black") + 
    #ylab("Police Killings per 100,000 Residents") +
    #xlab("Median State Income in US Dollars") +
    #scale_size_continuous(guide = 'none', range = c(3,20)) +
    scale_size_continuous((name = "State Population"),
                          breaks = c(1000000,30000000),
                          labels = c("1 million", "30 million"), range = c(3,20)) +
    theme_bw() +
    guides(fill = guide_legend(override.aes = list(size=10), nrow = 3)) +
    labs(title = "Police Killings vs. Percentage of People Living in Poverty by State",
         subtitle = "States with higher poverty rates tend to have higher frequencies of police killings",
         caption = "Source: The Washington Post", 
         x = "Poverty Rate in %", y = "Police Killings per 100,000 Residents") +
    theme(axis.text = element_text(size = 11),
          plot.title = element_text(size = 16, face = "bold")) +
    scale_fill_manual(values = c("#56B4E9", "#F0E442", "#0072B2", "#D55E00", "#CC79A7"))  
  
  plot2 <- ggplot(all_states, aes(x=long, y=lat, group = group)) + 
    geom_polygon(fill="grey", colour = "white") +
    coord_fixed(xlim = c(-130, -65), ylim = c(18, 55)) +
    geom_polygon(fill="#D55E00", data = filter(all_states, region %in% PacificNames)) +
    geom_polygon(fill="#56B4E9", data = filter(all_states, region %in% FrontierNames)) +
    geom_polygon(fill="#F0E442", data = filter(all_states, region %in% MidwestNames)) +
    geom_polygon(fill="#CC79A7", data = filter(all_states, region %in% SouthNames)) +
    geom_polygon(fill="#0072B2", data = filter(all_states, region %in% NorthEastNames)) +
    theme_void()
  
  l1 = ggplot_build(plot1)
  
  x1 = l1$layout$panel_scales_x[[1]]$range$range[1]
  x2 = l1$layout$panel_scales_x[[1]]$range$range[2]
  y1 = l1$layout$panel_scales_y[[1]]$range$range[1]
  y2 = l1$layout$panel_scales_y[[1]]$range$range[2]
  
  
  
  
  xdif = x2-x1
  ydif = y2-y1
  xmin  = x1 + (xleft*xdif)
  xmax  = x1 + (xright*xdif)
  ymin  = y1 + (ybottom*ydif)
  ymax  = y1 + (ytop*ydif) 
  
  
  g2 = ggplotGrob(plot2)
  plot3 = plot1 + annotation_custom(grob = g2, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax)
  plot3
  
  
  },width = 1020, height = 460)
  
  
  
})
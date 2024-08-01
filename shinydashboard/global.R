# Library Packages#
library(shiny)
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)
library(leaflet)
library(shinyWidgets)
library(leaflet.extras)
library(googleway)
library(htmlwidgets)
library(htmltools)
library(fontawesome)
library(sass)
library(sf)
library(here)
library(plotly)
library(lubridate)
library(tidylog)


# COMPILE CSS ----
sass(
  input = sass_file("www/sass-styles.scss"),
  output = "www/sass-styles.css",
  options = sass_options(output_style = "compressed") # OPTIONAL, but speeds up page load time by removing white-space & line-breaks that make css files more human-readable
)

#====== Global Options ==============

vernal_polygon <- st_read("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/VernalPools_Monitored2019.shp") %>% 
  st_transform(4326) %>% 
  # create a new column with location and pool_id
  mutate(location_pool_id = paste(Location, Pool_ID, sep = "_")) %>% 
  mutate(location_pool_id = str_replace_all(location_pool_id, ' ', '_'))

# NOTE: not new hydro data yet
hydro <- read_csv("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/hydro_data.csv") %>% 
  mutate(date = mdy_hm(date),
         date = as.Date(date)) %>% 
  mutate(water_year = water_year(date))

# cleaning percent cover labels for images
percent_cover <- read_csv("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/percent_cover_data.csv") %>% 
  mutate(type = case_when(type == "nonnative" ~ "Non-Native",
                          type == "native" ~ "Native",
                          type == "unknown" ~ "Unknown",
                          type == "other" ~ "Other"))

percent_cover$species <- gsub("_", " ", percent_cover$species)


# Source the water year function
source("~/MEDS/Courses/folder/vernal-shiny-dashboard/scratch/water-year-fun.R")



# abiotic data
abiotic <- read_csv("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/pc_abiotic_data.csv") %>% 
  select(location:depth_cm, location_pool_id)

summarized_abiotic <- abiotic %>%
  group_by(location_pool_id) %>% #created column
  summarise(across(where(is.numeric), mean, na.rm = TRUE))


vernal_polygon_abiotic <- vernal_polygon %>%
  left_join(summarized_abiotic, by = c("location_pool_id" = "location_pool_id"))



vernal_polygon_abiotic <- st_make_valid(vernal_polygon_abiotic)

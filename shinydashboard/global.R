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




# COMPILE CSS ----
sass(
  input = sass_file("www/sass-styles.scss"),
  output = "www/sass-styles.css",
  options = sass_options(output_style = "compressed") # OPTIONAL, but speeds up page load time by removing white-space & line-breaks that make css files more human-readable
)

#====== Global Options ==============

vernal_polygon <- st_read(here("shinydashboard", "data", "VernalPools_Monitored2019.shp")) %>% 
  st_transform(4326)

# abiotic <- read_csv("shinydashboard/data/pc_abiotic_data.csv")
# 
# head(abiotic)


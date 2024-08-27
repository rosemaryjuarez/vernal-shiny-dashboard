vernal_polygon <- st_read("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/VernalPools_Monitored2019.shp") %>% 
  st_transform(4326) %>% 
  clean_names() %>% 
  # create a new column with location and pool_id
  mutate(location_pool_id = paste(location, pool_id, sep = "_")) %>% 
  mutate(location_pool_id = str_replace_all(location_pool_id, ' ', '_')) %>% 
  mutate(location = case_when(
    location == "Del Sol" ~ "delsol_caminocorto",
    location == "CC" ~ "delsol_caminocorto",
    location == "WCB" ~ "west_campus",
    location == "NP" ~ "north_parcel",
    location == "Storke" ~ "storke_ranch",
    location == "Sierra Madre Housing" ~ "sierra_madre",
    location == "Ellwood" ~ "ellwood_mesa",
    TRUE ~ location )) %>%
  mutate(pool_id = case_when(
    pool_id == "Santa Barbara Vernal Pool" ~ "Santa Barabra",
    pool_id == "Santa Catalina Vernal Pool" ~ "Santa Catalina",
    pool_id == "Santa Cruz Vernal Pool" ~ "Santa Cruz",
    pool_id == "San Miguel Vernal Pool" ~ "San Miguel",
    pool_id == "Santa Rosa Vernal Pool" ~ "Santa Rosa",
    TRUE ~ pool_id )) %>%
  mutate(location = sapply(location, to_snake_case),            # Apply to_snake_case to 'location' column
         location_pool_id = paste(location, pool_id, sep = "_")) %>%  # Create new column combining 'location' and 'pool_id'
  mutate(location_pool_id = sapply(location_pool_id, to_snake_case)) %>%
  mutate(location_pool_id = paste(location, pool_id, sep = "_")) %>%
  mutate(location_pool_id = str_replace_all(location_pool_id, ' ', '_')) %>%
  select(-global_id)


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

write_csv(hydro, "~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/hydro_data.csv", append = FALSE )

write_csv(percent_cover, "~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/percent_cover_data.csv", append = FALSE)

# abiotic data
abiotic <- read_csv("~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/pc_abiotic_data.csv") %>% 
  select(location:depth_cm, location_pool_id)

summarized_abiotic <- abiotic %>%
  group_by(location_pool_id) %>% #created column
  summarise(across(where(is.numeric), mean, na.rm = TRUE))


vernal_polygon_abiotic <- vernal_polygon %>%
  left_join(summarized_abiotic, by = c("location_pool_id" = "location_pool_id"))



vernal_polygon_abiotic <- st_make_valid(vernal_polygon_abiotic)


# adding month to abiotic
vernal_polygon_abiotic <- vernal_polygon_abiotic %>%
  mutate(month = month(gps_date, label = TRUE, abbr = FALSE),
         year = year(gps_date),
         research_conducted_status = ifelse(is.na(site_area_m2), "Non-Active Monitoring", "Active Monitoring")) %>% 
  mutate(year = case_when(year == 1899 ~ 2020,
                          TRUE ~ 2019))


st_write(vernal_polygon_abiotic, "~/MEDS/Courses/folder/vernal-shiny-dashboard/shinydashboard/data/vernal_polygon_abiotic.shp",
         append = FALSE)

server <- function(input, output, session) {
  
  # Define the reactive value
  selected_polygon <- reactiveVal(NULL)
  
  #============== Simple Leaflet Plot for Data ==================
  
  
  #------------------
  #       map
  # -----------------
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -119.8489, lat = 34.4140, zoom = 15) %>% 
      addPolygons(data = vernal_polygon_abiotic,
                  fillColor = "blue",
                  fillOpacity = 0.7,
                  color = "black",
                  weight = 1,
                  layerId = ~location_pool_id,
                  popup = ~paste0("Location-Pool ID: ", location_pool_id, "<br>",
                                  "Site Area(meter squared): ", site_area_m2, "<br>",
                                  "Pool Area(meter squared):", pool_area_m2, "<br>",
                                  "Pool Circumference(ft): ", pool_circumference_ft, "<br>",
                                  "Pool Edge Ratio: ", pool_edge_ratio, "<br>",
                                  "Edge Distance Max: ", edge_distance_max, "<br>",
                                  "Restoration Year: ", restoration_year, "<br>",
                                  "Time Since: ", time_since, "<br>",
                                  "Period: ", period, "<br>",
                                  "Depth(cm): ", depth_cm, "<br>"
      ))
  })
  
  #============== Simple Leaflet Plot for Data END ==================
  
  
  #1
  filtered_pools <- reactive({
    if (input$location_pool_size_select == "All") {
      vernal_polygon_abiotic
    } else if (input$location_pool_size_select == "Greater than 1") {
      vernal_polygon_abiotic %>% filter(pool_area_m2 > 4046.86)  # 1 acre = 4046.86 m^2
    } else {
      vernal_polygon_abiotic %>% filter(pool_area_m2 <= 4046.86)
    }
  })
  
  #2
  observe({
    updateSelectizeInput(session, "location_pool_id_select",
                         choices = unique(filtered_pools()$location_pool_id),
                         selected = character(0))
  })
  
  # Reactive for date filtering
  filtered_dates <- reactive({
    req(input$month_select, input$year_select)
    

    vernal_polygon_abiotic %>%
      filter(
        month(GPS_Date) %in% match(input$month_select, month.name),
        year(GPS_Date) %in% input$year_select
      )
  })
  
  
  # Reactive for final filtered data
  final_filtered_data <- reactive({
    req(input$location_pool_id_select)
    
    filtered_dates() %>%
      filter(location_pool_id %in% input$location_pool_id_select)
  })
  
  # Update the map
  observe({
    leafletProxy("map") %>%
      clearShapes() %>%
      addPolygons(data = final_filtered_data(),
                  fillColor = "blue",
                  fillOpacity = 0.7,
                  color = "black",
                  weight = 1,
                  layerId = ~location_pool_id,
                  popup = ~paste0("Location-Pool ID: ", location_pool_id, "<br>",
                                  "Site Area(meter squared): ", site_area_m2, "<br>",
                                  "Pool Area(meter squared):", pool_area_m2, "<br>",
                                  "Pool Circumference(ft): ", pool_circumference_ft, "<br>",
                                  "Pool Edge Ratio: ", pool_edge_ratio, "<br>",
                                  "Edge Distance Max: ", edge_distance_max, "<br>",
                                  "Restoration Year: ", restoration_year, "<br>",
                                  "Time Since: ", time_since, "<br>",
                                  "Period: ", period, "<br>",
                                  "Depth(cm): ", depth_cm, "<br>"
                  ))
  })
  
  
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  #                                 DATAVIZ reaction
  # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  # Create reactive plot
  output$viz_plot <- renderPlotly({
    req(input$viz_location_pool_id, input$viz_plot_type)
    
    if(input$viz_plot_type == "Water Level") {
      p <- hydro %>%
        filter(location_pool_id == input$viz_location_pool_id & water_year == input$viz_water_year) %>%
        ggplot(aes(x = date, y = water_level_in)) +
        geom_line(col = "dodgerblue", size = 1) +
        scale_x_date(date_breaks = "2 weeks", date_labels = "%m-%d") + 
        labs(x = "Date", y = "Water Level (in)", title = "Weekly Water Level") +
        theme_classic()
    } else if(input$viz_plot_type == "Species Abundance") {
      species_abundance <- percent_cover %>%
        filter(location_pool_id == input$viz_location_pool_id & complete.cases(species) & species != "unlisted") %>%
        group_by(species, type) %>%
        summarise(percent_cover = sum(percent_cover, na.rm = TRUE))
      
      p <- species_abundance %>%
        ggplot(aes(reorder(species, percent_cover), percent_cover, fill = type)) +
        geom_col() +
        geom_text(aes(label = percent_cover), size = 3, hjust = -0.2) +
        scale_fill_manual(values = c("Native" = "#6B8E23", "Non-Native" = "#D2691E", "Unknown" = "gray40", "Other" = "gray50")) +
        labs(y = "Percent Cover", x = "Species", title = "Vegetation Abundance by Species", fill = "Type") +
        theme_minimal() +
        coord_flip()
    } else if(input$viz_plot_type %in% c("Native Cover", "Non-Native Cover", "Species Cover")) {
      y_var <- switch(input$viz_plot_type,
                      "Native Cover" = "sum_of_native_cover_automatically_calculated",
                      "Non-Native Cover" = "sum_of_non_native_cover_automatically_calculated",
                      "Species Cover" = "percent_cover")
      
      df <- percent_cover %>%
        filter(location_pool_id == input$viz_location_pool_id)
      
      if(input$viz_plot_type == "Species Cover") {
        df <- df %>% filter(species == input$viz_species)
      }
      
      p <- ggplot(df, aes_string("transect_distance_of_quadrat", y_var)) +
        geom_point() +
        geom_smooth(se = FALSE, method = "lm", formula = y ~ poly(x, 2)) +
        theme_minimal() +
        labs(x = "Transect Distance of Quadrat",
             y = input$viz_plot_type,
             title = paste(input$viz_plot_type, "by Transect Distance"))
    }
    
    ggplotly(p)
  })
  
  
  
  
  
}


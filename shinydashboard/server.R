server <- function(input, output, session) {
  
  # Define the reactive value
  selected_polygon <- reactiveVal(NULL)
  
  # Define color palette
  status_colors <- c("Active Monitoring" = "blue", "Non-Active Monitoring" = "orange", "Unknown" = "gray")
  
  legend_colors <- c("blue", "orange")
  legend_labels <- c("Active Monitoring", "Non-Active Monitoring")
  
  # Create a color mapping function with debugging
  colorMapping <- function(status) {
    colors <- sapply(status, function(s) {
      color <- status_colors[s]
      if (is.null(color) || is.na(color)) {
        print(paste("Unexpected status:", s))
        return("gray")  # Default color for unexpected status
      }
      return(color)
    })
    print("Unique statuses:")
    print(unique(status))
    print("Mapped colors:")
    print(unique(colors))
    return(colors)
  }
  
  output$map <- renderLeaflet({
    print("Rendering initial map")
    print("Unique research_conducted_status values:")
    print(unique(vernal_polygon_abiotic$research_conducted_status))
    
    # Assign colors based on status, handling NA values
    vernal_polygon_abiotic$fill_color <- sapply(vernal_polygon_abiotic$research_conducted_status, function(status) {
      if (is.na(status)) {
        return(status_colors["Unknown"])
      } else if (status %in% names(status_colors)) {
        return(status_colors[status])
      } else {
        return(status_colors["Unknown"])
      }
    })
    
    print("Unique fill_color values:")
    print(unique(vernal_polygon_abiotic$fill_color))
    
    leaflet() %>%
      addTiles() %>%
      setView(lng = -119.8489, lat = 34.4140, zoom = 15) %>%
      addPolygons(data = vernal_polygon_abiotic,
                  fillColor = ~fill_color,
                  color = "black",
                  weight = 1,
                  opacity = 1,
                  fillOpacity = 0.7,
                  layerId = ~location_pool_id,
                  popup = ~paste0("Location-Pool ID: ", location_pool_id, "<br>",
                                  "Research Status: ", ifelse(is.na(research_conducted_status), "Unknown", research_conducted_status), "<br>",
                                  "Site Area (m²): ", round(site_area_m2, 2), "<br>",
                                  "Pool Area (m²): ", round(pool_area_m2, 2), "<br>",
                                  "Pool Circumference (ft): ", round(pool_circumference_ft, 2), "<br>",
                                  "Pool Edge Ratio: ", round(pool_edge_ratio, 2), "<br>",
                                  "Edge Distance Max: ", round(edge_distance_max, 2), "<br>",
                                  "Restoration Year: ", restoration_year, "<br>",
                                  "Time Since: ", time_since, "<br>",
                                  "Period: ", period, "<br>",
                                  "Depth (cm): ", round(depth_cm, 2))
      ) %>%
addLegend(position = "bottomright",
          colors = legend_colors,
          labels = legend_labels,
          title = "Research Status",
          opacity = 1)
  })
  
  # Reactive function for filtered data
  filtered_data <- reactive({
    print("Filtering data...")
    print(paste("Pool size:", input$location_pool_size_select))
    print(paste("Month:", paste(input$month_select, collapse = ", ")))
    print(paste("Year:", paste(input$year_select, collapse = ", ")))
    print(paste("Location-Pool ID:", paste(input$location_pool_id_select, collapse = ", ")))
    
    data <- vernal_polygon_abiotic
    
    # Filter by pool size
    if (!is.null(input$location_pool_size_select) && input$location_pool_size_select != "All") {
      selected_interval <- which(jenks_labels == input$location_pool_size_select)
      lower_bound <- jenks_breaks[selected_interval]
      upper_bound <- jenks_breaks[selected_interval + 1]
      data <- data[data$pool_area_m2 >= lower_bound & data$pool_area_m2 < upper_bound, ]
    }
    
    # Filter by month
    if (!is.null(input$month_select) && length(input$month_select) > 0) {
      data <- data[data$month %in% input$month_select, ]
    }
    
    # Filter by year
    if (!is.null(input$year_select) && length(input$year_select) > 0) {
      print("Filtering by year...")
      print(paste("Years selected:", paste(input$year_select, collapse = ", ")))
      print(paste("Unique years in data before filtering:", paste(unique(data$year), collapse = ", ")))
      
      data <- data[data$year %in% input$year_select, ]
      
      print(paste("Rows after year filtering:", nrow(data)))
      print(paste("Unique years in data after filtering:", paste(unique(data$year), collapse = ", ")))
    }
    
    # Filter by location_pool_id
    if (!is.null(input$location_pool_id_select) && length(input$location_pool_id_select) > 0) {
      data <- data[data$location_pool_id %in% input$location_pool_id_select, ]
    }
    
    print(paste("Filtered data rows:", nrow(data)))
    data
  })
  
  # Update the map
  observe({
    filtered <- filtered_data()
    
    print("Updating map...")
    print(paste("Number of polygons to display:", nrow(filtered)))
    print("Unique research_conducted_status values in filtered data:")
    print(unique(filtered$research_conducted_status))
    
    # Assign colors based on status, handling NA values
    filtered$fill_color <- sapply(filtered$research_conducted_status, function(status) {
      if (is.na(status)) {
        return(status_colors["Unknown"])
      } else if (status %in% names(status_colors)) {
        return(status_colors[status])
      } else {
        return(status_colors["Unknown"])
      }
    })
    
    print("Unique fill_color values in filtered data:")
    print(unique(filtered$fill_color))
    
    leafletProxy("map") %>%
      clearShapes() %>%
      addPolygons(data = filtered,
                  fillColor = ~fill_color,
                  color = "black",
                  weight = 1,
                  opacity = 1,
                  fillOpacity = 0.7,
                  layerId = ~location_pool_id,
                  popup = ~paste0("Location-Pool ID: ", location_pool_id, "<br>",
                                  "Research Status: ", ifelse(is.na(research_conducted_status), "Unknown", research_conducted_status), "<br>",
                                  "Site Area (m²): ", round(site_area_m2, 2), "<br>",
                                  "Pool Area (m²): ", round(pool_area_m2, 2), "<br>",
                                  "Pool Circumference (ft): ", round(pool_circumference_ft, 2), "<br>",
                                  "Pool Edge Ratio: ", round(pool_edge_ratio, 2), "<br>",
                                  "Edge Distance Max: ", round(edge_distance_max, 2), "<br>",
                                  "Restoration Year: ", restoration_year, "<br>",
                                  "Time Since: ", time_since, "<br>",
                                  "Period: ", period, "<br>",
                                  "Depth (cm): ", round(depth_cm, 2))
      )
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